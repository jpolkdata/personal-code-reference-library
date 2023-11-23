/***************************************************************************************************
	Rebuild all indexes for a specified set of tables that 	have fragmentation over a specific %
****************************************************************************************************/

--User parameters
DECLARE @reorganizeLimit FLOAT = 5; --We'll reorganize indexes above this % but less than the @rebuildLimit
DECLARE @rebuildLimit FLOAT = 30; --We'll rebuild indexes above this %
DECLARE @targetTables TABLE (TableName VARCHAR(100)); --We'll define the tables that we want to check below
INSERT INTO @targetTables (TableName) VALUES ('TABLE1'), ('TABLE2'), ('TABLE3');

--Initialize our working variables
DECLARE @tableName VARCHAR(100) = '';
DECLARE @indexName VARCHAR(100) = '';
DECLARE @avgFragmentation FLOAT = 0;
DECLARE @sql NVARCHAR(MAX) = '';
DECLARE @msg NVARCHAR(MAX) = '';

--Create a cursor that contains all the tables we want to target, and their indexes that have some level of fragmentation (> 0%)
DECLARE ix_cursor CURSOR FOR
SELECT
	T.[Name] as [TableName]
	,I.[Name] as [IndexName]
	,DDIPS.avg_fragmentation_in_percent AS [avgFragmentation]
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS DDIPS
JOIN sys.tables T on T.object_id = DDIPS.object_id AND T.[Name] IN (SELECT TableName FROM @targetTables)
JOIN sys.indexes I ON I.object_id = DDIPS.object_id AND DDIPS.index_id = I.index_id
WHERE DDIPS.database_id = DB_ID()
	and I.[Name] is not null
	AND DDIPS.avg_fragmentation_in_percent > 0
ORDER BY T.[Name], I.[Name]
	
--For each index, determine if we should REORGANIZE and/or REBUILD based on the fragmentation level
OPEN ix_cursor
FETCH NEXT FROM ix_cursor INTO @tableName, @indexName, @avgFragmentation
WHILE @@FETCH_STATUS = 0
BEGIN

	--Sanitize the inputs for the table and index name (safeguard against potential SQL injection)
	SET @tableName = QUOTENAME(@tableName);
    SET @indexName = QUOTENAME(@indexName);

	--Print information about the index that we are currently processing
	SET @msg = CONCAT('TABLE: ', @tableName, '; INDEX:', @indexName, '; FRAGMENTATION:', CAST(@avgFragmentation AS VARCHAR(100)));
	RAISERROR (@msg, 0, 1) WITH NOWAIT;

	--Re-organize the index if the fragmentation is within our threshold
	IF (@avgFragmentation BETWEEN @reorganizeLimit AND @rebuildLimit)
	BEGIN
		SET @sql = CONCAT('ALTER INDEX ', @indexName, ' ON ', @tableName, ' REORGANIZE');
		RAISERROR ('...REORGANIZE', 0, 1) WITH NOWAIT;
		EXEC sp_executesql @sql; 
	END

	--If the fragmentation level is above the % we specified, then go ahead and rebuild the index
	IF (@avgFragmentation >= @rebuildLimit)
	BEGIN
		SET @sql = CONCAT('ALTER INDEX ', @indexName, ' ON ', @tableName, ' REBUILD');
		RAISERROR ('...REBUILD', 0, 1) WITH NOWAIT;
		EXEC sp_executesql @sql;
	END 

	--Get the next index to process
	FETCH NEXT FROM ix_cursor INTO @tableName, @indexName, @avgFragmentation
END

CLOSE ix_cursor
DEALLOCATE ix_cursor;
