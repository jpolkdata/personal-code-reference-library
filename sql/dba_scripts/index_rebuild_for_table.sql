/**************************************************************************************************************************************************
	Rebuild all indexes for a given table that have fragmentation over a specific %
**************************************************************************************************************************************************/
DECLARE @tableName varchar(100) = 'Receivables'
DECLARE @indexName varchar(100)
DECLARE @avgFragmentation float
DECLARE @sql nvarchar(max)
DECLARE @msg NVARCHAR(MAX)

DECLARE ix_cursor CURSOR FOR
SELECT
	I.name as [IndexName],
	DDIPS.avg_fragmentation_in_percent AS 'avgFragmentation'
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS DDIPS
INNER JOIN sys.tables T on T.object_id = DDIPS.object_id AND T.name = @tableName
INNER JOIN sys.indexes I ON I.object_id = DDIPS.object_id
AND DDIPS.index_id = I.index_id
WHERE DDIPS.database_id = DB_ID()
	and I.name is not null
	AND DDIPS.avg_fragmentation_in_percent > 0
	
OPEN ix_cursor
FETCH NEXT FROM ix_cursor INTO @indexName, @avgFragmentation
WHILE @@FETCH_STATUS = 0
BEGIN

	SET @msg = 'TABLE: ' + @indexName + ' ' + CAST(@avgFragmentation AS varchar(100))
	RAISERROR (@msg, 0, 1) WITH NOWAIT IF (@avgFragmentation between 5 and 30)

	BEGIN
		SET @sql = 'ALTER INDEX ' + @indexName + ' ON ' + @tableName + ' REORGANIZE';
		exec sp_executesql @sql;
	END 

	IF (@avgFragmentation > 30)
	BEGIN
		SET @sql = 'ALTER INDEX ' + @indexName + ' ON ' + @tableName + ' REBUILD';
		exec sp_executesql @sql;
	END 

FETCH NEXT FROM ix_cursor INTO @indexName, @avgFragmentation
END

CLOSE ix_cursor
DEALLOCATE ix_cursor

