# Group By in LINQ To Turn Flat Rows Into Nested Rows

Let's say we're grabbing data from a database that returns it to us in the form of a list of these `GetEnemyActivityResult` objects. 
```
    public class GetEnemyActivityResult
    {
        public Guid ActivityId { get; set; }
        public int TypeId { get; set; }
        public int OptionKeyId { get; set; }
        public string Value { get; set; }

    }
```

There are different notifications that one of our fortresses generates when enemy activity is captured on camera. 

However, we need to map the objects into the EnemyActivity object format:

```
    public class EnemyActivity
    {
        public Guid ActivityId { get; set; }
        public int TypeId { get; set; }
        public IEnumerable<ActivityDetail> ActivityDetails { get; set; }
    }

    public class ActivityDetail
    {
        public int OptionKeyId { get; set; }
        public string Value { get; set; }
    }
```

Each record of enemy activity has a unique activity id, but there are some TypeIds that will have different OptionKeyIds associated with them that have completely different meanings to their value. When we get our information from the database in that first `GetEnemyActivityResult` format, they come in rows like:

```
ActivityId TypeId OptionKeyId Value
1            3        10       90
2            5        2        140
2            5        3        335
```

Imagine that before mapping, these were all objects in a list, `activity`:

```
activity[0] = { 
        ActivityId = 1, 
        TypeId = 3, 
        OptionKeyId = 10, 
        Value = 90 
    }; 

activity[1] = { 
        ActivityId = 2, 
        TypeId = 5, 
        OptionKeyId = 2, 
        Value = 140 
    }; 

activity[2] = { 
        ActivityId = 2, 
        TypeId = 5, 
        OptionKeyId = 3, 
        Value = 335 
    }; 
```

After mapping:

```
activityMapped[0] = { 
    ActivityId = 1, 
    TypeId = 3, 
    ActivityDetails = [
        { OptionKeyId = 10, Value = 90 }
        ]
    }; 

activityMapped[1] = {
    ActivityId = 2, 
    TypeId = 5, 
    ActivityDetails = [
        { OptionKeyId = 2, Value = 140 },
        { OptionKeyId = 3, Value = 335 }
        ]
    }; 
```

So how can we do this with a LINQ query? 

The first parameter of this GroupBy method is the keySelector function, with which you can extract the key for each element. In our case the key was the ActivityId, since that piece indicates an entirely unique notification for enemy alerts. 

The second parameter is the elementSelector, which is a function that maps each source element to an element in the grouping. In our case we want the rest of the information in the object. 

Lastly we have the resultSelector, which is a function that creates a result value from each group. So we pass in the key and the elements to generate a new EnemyActivity object using that key and elements. 


```
getActivityResults.GroupBy(
    res => res.ActivityId,
    res => new { res.TypeId, res.OptionKeyId, res.Value },
    (key, properties) => new EnemyActivity
    {
        ActivityId = key,
        TypeId = properties.First().TypeId,
        ActivityDetails = properties.Select(res => new ActivityDetail{
            OptionKeyId = res.OptionKeyId,
            Value = res.Value
            }).ToList()
    });
``

Hurray! Now we can get the notifications in the format that we want from our fortress. 