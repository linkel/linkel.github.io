One of our requests was timing out with an "Execution Timeout" error from the database. Looked like the query was taking so long that the service gave up. I had made changes to the stored procedure so I figured it was probably my fault. 

Interestingly, I found that this request was only happening for one company when requesting data that went back to over 30 days. A week or a month's data was fine, but two and three months was failing. This also was not happening for other companies. So it seemed that a change I made was resulting in a bottleneck somewhere. 

Started speaking with a very knowledgeable coworker for help. 

We grabbed the parameters that were getting passed into the stored procedure and ran them on the database directly. 1.5 minutes! Then we copied the stored procedure's code intending to modify a couple of parts that may have been the culprit, only to discover that the exact code of the stored procedure would finish running in 2 seconds! 

We compared the execution plan and found that the stored procedure itself was performing a join on a huge amount of rows early on in the process, whereas the fast code was performing that join later in the process once a lot of rows had been filtered out by other joins. 

We saw that the statistics of the table hadn't been updated in a week, and we'd recently added a large amount of data down into our staging database, so we updated the statistics with a query. 

```
UPDATE STATISTICS Example.Table (ExampleStats) WITH FULLSCAN
```

Still slow!

We also tried to clear the procedure cache (which is saved after first running a procedure to save the execution plan in memory).

```
SELECT plan_handle, st.text  
FROM sys.dm_exec_cached_plans   
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st  
WHERE text LIKE N'SELECT * FROM Example.Table%';  
```

Then you can use FREEPROCCACHE on the plan handle.

```
DBCC FREEPROCCACHE (0x060006001FDA270EC0104D05000000000000000000000000);  
```

This also didn't seem to change anything.

A big mystery. 

So to force the stored procedure to perform the culprit join later, we rewrote the query to separate the join out and perform the join after the other joins had occurred to populate the temporary table. Overall pretty weird. There must have been a reason why that was happening, but at this time I've no clue.
