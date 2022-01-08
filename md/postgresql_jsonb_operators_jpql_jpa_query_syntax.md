# PostgreSQL jsonb Operators and JPQL/JPA Query vs NativeQuery Syntax

Some time ago I needed to write a method containing a query in a data access layer of a Java Spring codebase that would obtain a sum of values in a jsonb column grouped by a site id in a PostgreSQL database. 

This sounded very straightforward, so I was surprised when I repeatedly hit small syntax roadblocks due to my lack of knowledge about Java Persistence API (JPA) Queries, the difference between a Query and a NativeQuery, what Java Persistence Query Language (JPQL) supports, and casting.

Let's say there's a table called Drafts that records information about these drafts of books and journals. There's authors, date created, date updated, and typical information like that. There's a jsonb column on it that contains more info that changes a lot or has to do with metadata. 

A jsonb (which stands for JSON Binary, probably) column in PostgreSQL stores JavaScript Object Notation (JSON, you know) data in a binary format that's slower to input because it needs to convert it from the text to the binary format, but faster to process since it's already in a parsed format. 

I think we use it because for those metadata changes, we don't need to update the table schema if we had to add more fields--we just slap it all in the jsonb column. 

Let's say the jsonb column has an entry "size" that gives how many bytes the draft is, kind of like pages in a book but in bytes for certain calculation reasons.

These jsonb columns have their own special syntax for inputting data. Well, the first hurdle I smashed into was that JPQL doesn't support the jsonb arrow operator. In the file I was adding a method to, all the other methods were using Query and TypedQuery. They have a syntax that looks similar to SQL and makes use of the Java class that you've defined.

For example, if the class is something like:

```
@Entity
@Table
public class Draft {
  private UUID luid;
  private Integer siteId;
  private Date updatedAt;
  private DraftProperties properties;
}
```

A method that uses a Query to list out all of the drafts that haven't been updated since a certain time could be:

```
public List<Draft> listAllDraftsNotUpdatedSince(Instant time) {
  TypedQuery<Draft> q = entityManager.createQuery(
    "SELECT d FROM Draft d " +
      "WHERE d.updatedAt < :time",
    Draft.class);

  q.setParameter("time", Date.from(time));
  return q.getResultList();
}
```

Note how the fields on that class are accessed like d.updatedAt, and it's in camelcase rather than what the PostgreSQL column would be, updated_at.

When I wrote my query initially, I used that syntax with

```
SELECT siteId, COALESCE(SUM((properties->>'size')::bigint), 0) AS sizeInBytes
FROM Draft d WHERE d.siteId in (:siteIds)
GROUP BY d.siteId
```

and quickly found that this `->>` gave me an error. That arrow operator is a PostgreSQL specific JSON operator so JPQL doesn't support it (it just supports the generic SQL dialect parts). So then I had to go to a native query instead.

```
SELECT site_id, COALESCE(SUM((properties->>'size')::bigint), 0) AS sizeInBytes
FROM super_duper_drafts d WHERE d.site_id in (:siteIds)
GROUP BY d.site_id
```

At this point there was one more minor problem--casting it to a bigint using the two semicolons required me to escape the semicolons because semicolons are used by JPA to indicate a named parameter prefix.

```
SELECT site_id, COALESCE(SUM((properties->>'size')\\:\\:bigint), 0) AS sizeInBytes
FROM super_duper_drafts d WHERE d.site_id in (:siteIds)
GROUP BY d.site_id
```

Cool. And finally I needed to execute this query, return a map containing an entry for each row returned, where the value in the first column would be the map key and the value in the second column would be the map value.

```
public Map<Integer, Long> getSizeInBytes(Set<Integer> siteIds) {
        Query query = entityManager.createNativeQuery(
            "SELECT site_id, COALESCE(SUM((properties->>'size')\\:\\:bigint), 0) AS sizeInBytes " +
            "FROM super_duper_drafts d " +
                "WHERE d.site_id IN (:siteIds) " +
                "GROUP BY d.site_id");

        query.setParameter("siteIds", siteIds);
        Map<Integer, Long> resultMap = new HashMap<>();

        // In the real code this bit isn't located here
        // but I've placed it here for illustrative purposes
        Function<Object, Integer> OBJECT_TO_INTEGER_FUNCTION =
            obj -> ((Number) obj).intValue();
        Function<Object, Long> OBJECT_TO_LONG_FUNCTION =
            obj -> ((Number) obj).longValue();

        for (Object result : query.getResultList()) {
            Object[] row = (Object[]) result;
            resultMap.put(OBJECT_TO_INTEGER_FUNCTION.apply(row[0]), OBJECT_TO_LONG_FUNCTION.apply(row[1]));
        }

        return resultMap;
    }
```

So to recap:

1. Use native queries for database-specific operators like jsonb's arrow syntax.
2. Escape semicolon characters in a native query due to named parameter prefix clash.