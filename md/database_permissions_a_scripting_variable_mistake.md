Database Permissions, Scripting Variable Mistake

In the database, we use scripting variables to hold the service account usernames across our different integration, staging, validation, and production environments. We declare these variables in the project (sqlproj) and it's editable through any text editor, though Visual Studio spruces up the appearance into a table. 

There are different publish profiles for each environment and the xml file for each will initialize the scripting variables to the desired values. 

I created a new listener service the other day that makes a database table update based on messages on topics it was consuming. 

I went over to the publish profile for the integration environment and supplied it with a scripting variable key value pair.

```
<SqlCmdVariable Include="ServiceAccount_EvalBackfill"><Value>COMPANY\integ_EvalBackfill</Value></SqlCmdVariable>
```

I also made it a user role via

```
create role [EvalBackfill] authorization [dbo];
```

Then inserted that role, and made permissions for it. 

```
The columns are:
PermissionAction, PermissionName, SchemaName, ObjectName, ObjectType, PermissionRecipient
for something like:
('grant', 'execute', null, 'myschema', 'schema', 'EvalBackfill')
that gets inserted into the permissions 
```

I pushed it. For these services we use OpenShift (containerization platform that uses Docker containers managed by Kubernetes), which automatically deploys successful builds. Boom! Deployed! But nothing happened when a message came through. I logged onto Kibana (data visualization for Elasticsearch) and filtered for my service. 

Found this:

```
exception_message	   	Login failed for user 'COMPANY\integ_EvalBackfill'.
exception_method	   	Void HandlePolicyResult(Polly.OutcomeType, System.Exception)
```

Hey, didn't I make the user role and permission? But wait! Turns out I forgot to declare the scripting variable in the first place. Scripting variables need to be declared prior to being initialized. I had to go into Visual Studio, navigate over to variables within properties, and add a line for declaring the variable.

If you open up the sqlproj instead of viewing it in Visual Studio, it looks like this:

```
    <SqlCmdVariable Include="ServiceAccount_EvalBackfill">
      <DefaultValue>
      </DefaultValue>
      <Value>$(SqlCmdVar__11)</Value> <--- whatever number it is on the row
    </SqlCmdVariable>
```

With that added, my service was able to successfully make the database call. All good!