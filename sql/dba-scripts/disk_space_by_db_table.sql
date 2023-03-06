/***
  Get some stats about the number of data rows as well as the amount of disk space is being
  used. We are filtering to just tables that match a specific naming pattern and contain
  at least 1 data row.
***/
SELECT 
      t.[Name] AS TableName
    , s.[Name] AS SchemaName
    , p.[Rows]
    , SUM(a.total_pages) * 8 AS TotalSpaceKB
    , CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB
    , SUM(a.used_pages) * 8 AS UsedSpaceKB
    , CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB
    , (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB
    , CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB
	--, 'DROP TABLE ' + 
FROM sys.tables t
JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
JOIN sys.allocation_units a ON p.partition_id = a.container_id
LEFT JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
	AND (p.[Rows] > 0 OR t.[Name] LIKE 'Bulk%') --Include tables that contain at least 1 row and are named a specific way
GROUP BY 
    t.[Name], s.[Name], p.[Rows]
ORDER BY 
    TotalSpaceMB DESC, t.[Name]

