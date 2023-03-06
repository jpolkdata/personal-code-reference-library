
/**************************************************************************************************************************************************
    Loop through all databases and run a query
**************************************************************************************************************************************************/
/* Loop through all DBs to execute a set of queries */
EXECUTE master.sys.sp_MSforeachdb 
'USE [?]; 
if db_name(db_id()) LIKE ''DW%'' 
Begin 
    --query goes here
end'


/**************************************************************************************************************************************************
    Loop through all databases and identify which ones contain a specific table. Temp table is used here to give us more control 
    over the output in our final select (for this example we are just sorting the results)
**************************************************************************************************************************************************/
SET NOCOUNT ON;
DECLARE @sql NVARCHAR(MAX)

--Create the temp table
DROP TABLE IF EXISTS #Temp;
CREATE TABLE #temp
(
    DatabaseName NVARCHAR(MAX)
    ,TableName NVARCHAR(MAX)
)

--Query to get your DB/table/column info
SET @sql = 'USE ? 
SELECT DISTINCT TABLE_CATALOG, TABLE_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = ''Patients''
ORDER BY TABLE_CATALOG, TABLE_NAME'

--Insert the output of the loop into the temp table
INSERT INTO #temp(DatabaseName, TableName)
EXEC sp_MSforeachdb @sql;

--Output the results
SELECT * FROM #temp ORDER BY 1
DROP TABLE IF EXISTS #Temp;


/**************************************************************************************************************************************************
    Loop through SPECIFIC dbs and run a query via a cursor
**************************************************************************************************************************************************/
DECLARE 
    @DBName VARCHAR(100)
    ,@sql NVARCHAR(MAX);

DECLARE cursDB CURSOR FOR 
SELECT [Name] 
FROM sys.databases 
WHERE [Name] LIKE 'DWStaging%' 
ORDER BY 1;

OPEN cursDB;
FETCH NEXT FROM cursDB INTO @DBName;

WHILE @@FETCH_STATUS = 0
    BEGIN

        SET @sql = 'USE [' + @DBName + ']; SELECT DB_NAME()';
        --PRINT @sql;
        EXEC sp_executesql @sql;
        
    FETCH NEXT FROM cursDB INTO @DBName;

    END;

CLOSE cursDB;
DEALLOCATE cursDB;

