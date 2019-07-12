# How many SQL records are associated with more than one of another record type? 

Let's say there's an application that captures snippets of video of moments in a soccer game. There's an algorithm that decides when to save a clip of video, perhaps judging off of a lot of exciting player movement or crowd intensity or velocity of the ball. The video is intended as an aid to coaching players. Our focus today is a feature where other players or coaches can see the video snippets and can give kudos to the player involved. This information is stored across four tables of interest in the database in a higher normal form. 

Perhaps the tables look something like this. 

```
Table Kudos
id
GivenToPlayerId
GivenByUserId
CreationDate
Comments

Table PlayerDevelopmentRecord
id
PlayerId
DevelopmentTypeId
KudosId
CreationDate

Table PlayerDevelopmentRecordObjects
id
PlayerDevelopmentRecordId
MomentId
CreationDate

Table Moments
id
Date
TeamId
PlayerId
VenueId
CameraId
CoachId
ImprovementLogId
```

Let's say that we're working on a new application that will consume some of this previously created information. A decision-maker wants to know how many Moments have more than one Kudos in our live production servers. 

I know that I'll have to connect the Moments table with the Kudos table. 

By default, if I don't specify join type then it is an inner join. 

The following query will inner join all of these tables together using their foreign keys and select everything from that. An inner join in SQL is the same as a relational algebra Theta Join, represented by the butterfly symbol with subscript specifying the condition that I'm joining on (aka the ON clause in SQL). 

```
SELECT * FROM [db].[Kudos] kd
	join [db].[PlayerDevelopmentRecord] pdr ON pdr.KudosId = kd.id
	join [db].[PlayerDevelopmentRecordObjects] pdro ON pdro.PlayerDevelopmentRecordId = pdr.id
	join [db].[Moments] m ON m.id = pdro.MomentId
```

Now that I have a query that combines the tables as desired, I want to use the aggregation function COUNT to return the number of items found in a group. I've got to specify a group, though. Right now I have separate rows for every entry, but I want to group my entries by the MomentId so that all rows with the same MomentId are grouped together. 

I can make my first result a table, and then select relevant fields (including the COUNT function), group by the EventId, and receive a count back. 

```
with myTable as (
SELECT * FROM [db].[Kudos] kd
	join [db].[PlayerDevelopmentRecord] pdr ON pdr.KudosId = kd.id
	join [db].[PlayerDevelopmentRecordObjects] pdro ON pdro.PlayerDevelopmentRecordId = pdr.id
	join [db].[Moments] m ON m.id = pdro.MomentId
)
SELECT MomentId, COUNT(*) count
FROM myTable
GROUP BY MomentId
HAVING COUNT(*) > 1
```

A few points:

1. The "with" and "as" are what let me specify a temporary result set named whatever I want (in this case myTable). This is also known as a common table expression. 
2. I don't have to write "count" after COUNT(*), but it's naming the column that results. I could call that "count" whatever I want. 
3. GROUP BY is how I collect rows with the same value together into one row. This permits me to run aggregation functions on it. 
4. "HAVING" specifies a search condition for groups. 
5. Capitalization doesn't matter, but helps for readability.  

So now that I've got my query, I am able to find out how many Moments have more than one Kudos. 

To check that I did it correctly, I created additional Kudos on Moments and ran the query on our development database to make sure that the Kudos incremented when I added them on a Moment, and also that Kudos don't increment on that Moment if I add them on a different Moment even if it was the same player. 

