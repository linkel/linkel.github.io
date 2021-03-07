# SQL Server GUID Sort Order

An old coworker reminded me about the time SQL Server was sorting GUIDs (uniqueidentifiers) completely against my intuition.

I vaguely recall that we were looking at the "default" sort order of a table that had a GUID as a primary key, without providing an ORDER BY clause. Without an ORDER BY clause, there is no order guaranteed. But, in some cases it just so happens that when you query it, the data comes back "sorted" by the primary key. This is probably because in MSSQL when you create a primary key for a table, a clustered index also gets created if there isn't an existing one, and a clustered index determines the physical order of the rows in the table. So it's just by chance that SQL Server decides that returning the results following the physical order of the rows performs well. It is not guaranteed that you'd get this order every time.

Anyways, my coworker saw the order of the results coming back and figured that it was returning the results in the order of the primary key, the GUID. But there was something a little odd about the sorting...

I imagine most folks expect a series of GUIDs to look like this when sorted:

```
1fffffff-eeee-3ddd-cccc-3bbbbbbbbbbb
1fffffff-eeee-dddd-3ccc-3bbbbbbbbbbb
1fffffff-eeee-dddd-cccc-3bbbbbbbbbbb
2fffffff-eeee-2ddd-cccc-1bbbbbbbbbbb
2fffffff-eeee-dddd-2ccc-1bbbbbbbbbbb
2fffffff-eeee-dddd-cccc-1bbbbbbbbbbb
3fffffff-eeee-1ddd-cccc-2bbbbbbbbbbb
3fffffff-eeee-dddd-1ccc-2bbbbbbbbbbb
3fffffff-eeee-dddd-cccc-2bbbbbbbbbbb
ffffffff-1eee-dddd-cccc-2bbbbbbbbbbb
ffffffff-2eee-dddd-cccc-1bbbbbbbbbbb
ffffffff-3eee-dddd-cccc-3bbbbbbbbbbb
```

Looking at the first digit, we have a selection of 1, 2, 3, and f, and 1 < 2 < 3 < f. Then within the set that starts with a 1, we see that 3 < d so that determines the ordering of the first two entries. For the 2nd and 3rd entry, they're identical until the block where 3 < c, so that settles that ordering. Likewise for the rest of these.

But in SQL Server if you order by a GUID column it doesn't end up looking like the above.

Instead it looks like:

```
2fffffff-eeee-dddd-2ccc-1bbbbbbbbbbb
2fffffff-eeee-2ddd-cccc-1bbbbbbbbbbb
ffffffff-2eee-dddd-cccc-1bbbbbbbbbbb
2fffffff-eeee-dddd-cccc-1bbbbbbbbbbb
3fffffff-eeee-dddd-1ccc-2bbbbbbbbbbb
3fffffff-eeee-1ddd-cccc-2bbbbbbbbbbb
ffffffff-1eee-dddd-cccc-2bbbbbbbbbbb
3fffffff-eeee-dddd-cccc-2bbbbbbbbbbb
1fffffff-eeee-dddd-3ccc-3bbbbbbbbbbb
1fffffff-eeee-3ddd-cccc-3bbbbbbbbbbb
ffffffff-3eee-dddd-cccc-3bbbbbbbbbbb
1fffffff-eeee-dddd-cccc-3bbbbbbbbbbb
```

You can probably see that in the above, that last 6 bytes (1 byte = 8 bits = 2 hex digits) are the most significant, as opposed to in the "expected" sort order of a GUID or a string sort (lexicographic) where the first digit is the most significant.

SQL Server breaks a GUID into 5 "byte groups", delimited by the dash. The significance of the byte groups goes from right to left. Within each byte group, significance depends on which byte group it is--I'll get to that in a moment.

In the above example you can see it goes from 1 < 2 < 3 for that rightmost byte group. Between the first two entries, the second to rightmost byte group (2ccc vs cccc) has 2 < c, so that determines their order. The 2nd and 3rd entries have a difference in the third to rightmost byte group (2ddd vs dddd) so that determines the order there. Likewise for the following one.

My example above, to keep it cleaner, just has digits changed at the leftmost digit in each byte group. In actuality it'd be one step more confusing since the byte groups have different significance directions.

The sort order within a byte group is dependent on which one it is. I'm going to go from left to right for my own sanity.

Byte Group 1 has significance in left to right order.
Byte Group 2 has significance in left to right order.
Byte Group 3 has significance in left to right order.
Byte Group 4 has significance in right to left order.
Byte Group 5 has significance in right to left order.

To better illustrate, here's another set of example GUIDS sorted in SQL Server's order:

```
01000000-0000-0000-0000-000000000000
00010000-0000-0000-0000-000000000000
00000100-0000-0000-0000-000000000000
00000001-0000-0000-0000-000000000000
00000000-0100-0000-0000-000000000000
00000000-0001-0000-0000-000000000000
00000000-0000-0100-0000-000000000000
00000000-0000-0001-0000-000000000000
00000000-0000-0000-0010-000000000000
00000000-0000-0000-0100-000000000000
00000000-0000-0000-0000-000000000001
00000000-0000-0000-0000-000000000100
00000000-0000-0000-0000-000000010000
00000000-0000-0000-0000-000001000000
00000000-0000-0000-0000-000100000000
00000000-0000-0000-0000-010000000000
```

Witness the delicious clarity of the final byte group right-to-left most significant digit ordering in the last 6 entries.

In conclusion, if you ever need to ORDER BY uniqueidentifiers, you can do it and it will be consistent. Just remember that it'll differ from the typical sort order!

5 "byte groups", delimited by a dash.
The significance of the byte groups goes from right to left.
The first three (counting from the left) byte groups have significance within the group in left to right order, and the last two byte groups have significance from right to left order.
