
/* Search within stored proc definitions */
SELECT DISTINCT
 o.name AS Object_Name
,o.type_desc
,m.definition
FROM sys.sql_modules m
INNER JOIN sys.objects o
ON m.object_id = o.object_id
WHERE m.definition like '%mpi%'

/* See when db objects were last modified */
SELECT type, name, create_date, modify_date 
FROM sys.objects
WHERE type = 'U' --TABLES
OR type = 'P' --STORED PROCS
ORDER BY modify_date DESC

/* Format a number with commas */
SELECT FORMAT(COUNT(*),'#,#0')

/* Format a date with a custom string */
SELECT FORMAT(GETDATE(), 'yyyyMM')
SELECT FORMAT(GETDATE(), 'yyyy-MM-dd')

/* Get YYYY-MM from a date field */
SUBSTRING(CONVERT(VARCHAR,[DateField],112),0,5) + '-' + SUBSTRING(CONVERT(VARCHAR,[DateField],112),5,2)

/* Calculate the estimated runtime between two timestamps*/
SELECT
	CASE
		WHEN (ISDATE(EarliestStart) = 1 AND ISDATE(LatestEnd) = 1) THEN CONVERT(VARCHAR(12), DATEADD(MS, DATEDIFF(MS, EarliestStart, LatestEnd), 0), 114)
		ELSE NULL
	END AS EstRuntime
FROM [TABLE]

/* Force a query error */
RAISERROR('TEST',0,1);

/* Check for the existence of a table and drop it if it exists */
DROP TABLE IF EXISTS Temp

/* Check the max value length for each column in a table */
SELECT 'SELECT ''' + COLUMN_NAME + ''', MAX(LEN([' + COLUMN_NAME + '])) FROM xxx UNION'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'xxx'

/* Add a rowhash to a query */
SELECT 
	'0x' + CONVERT(VARCHAR(70),(HASHBYTES('SHA1',
		COALESCE(CAST([FIELD1] AS VARCHAR(100)),'')
		+ COALESCE(CAST([FIELD2] AS VARCHAR(100)),'')
		+ COALESCE(CAST([FIELD3] AS VARCHAR(100)),'')
		)),2) AS MyRowHash
FROM MyTable

/* Check the datatype for a particular query using a temp table */
SELECT TOP 5 * INTO #TempTable FROM BaseTable;
EXEC tempdb.dbo.sp_help N'#TempTable';
IF OBJECT_ID('tempdb..#TempTable') IS NOT NULL DROP TABLE #TempTable;

/* Take the larger of multiple field values */
--https://stackoverflow.com/questions/71022/sql-max-of-multiple-columns
SELECT 
        , (SELECT MAX(v) FROM (VALUES (tr.create_timestamp), (tr.modify_timestamp), (td.create_timestamp), (td.modify_timestamp)) AS VALUE(v) ) AS UpdateDate 
--, tr.create_timestamp AS TransCreateDate
--, tr.modify_timestamp AS TransUpdateDate
--, td.create_timestamp AS TransDetailCreateDate
--, td.modify_timestamp AS TransDetailUpdateDate
FROM tr

/* Check for open transactions */
DBCC opentran

--Parse a concatenated field into its individual parts using XML
SELECT 
         sourceVisitID
        ,CONVERT(XML,'<x><y>' + REPLACE(sourceVisitID,'|', '</y><y>') + '</y></x>').value('/x[1]/y[1]','varchar(100)') AS [Enterprise ID]
        ,CONVERT(XML,'<x><y>' + REPLACE(sourceVisitID,'|', '</y><y>') + '</y></x>').value('/x[1]/y[2]','varchar(100)') AS [Initial Report Date]
        ,CONVERT(XML,'<x><y>' + REPLACE(sourceVisitID,'|', '</y><y>') + '</y></x>').value('/x[1]/y[3]','varchar(100)') AS [Admit Date]
,VisitID
,PatientID
FROM DBNAME.dbo.Visits 

/* Remove duplicate rows from a table */
WITH x AS
(
        SELECT col1, col2,
        ROW_NUMBER() OVER (PARTITION BY col1, col2 ORDER BY col1) AS rn
        FROM Youtable
)
DELETE
FROM x
WHERE rn > 1

/* Add the row number to your output */
SELECT 
  ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS RowNumber
, Field1
, Field2
FROM Table

/* Get the larger of multiple values */
SELECT MAX(v)
FROM (VALUES
(ISNULL(appt.create_timestamp,'')), (ISNULL(appt.modify_timestamp,'')) --appointment was created or updated
, (ISNULL(pe.create_timestamp,'')), (ISNULL(pe.modify_timestamp,'')) --patient_encounter was created or updated
) AS VALUE(v)

/* Decode and encode a string from Base64 and back */
declare @source varbinary(max), @encoded varchar(max), @decoded varbinary(max)
set @source = convert(varbinary(max), 'TEST')
set @encoded = cast('' as xml).value('xs:base64Binary(sql:variable("@source"))', 'varchar(max)')
set @decoded = cast('' as xml).value('xs:base64Binary(sql:variable("@encoded"))', 'varbinary(max)')
select
convert(varchar(max), @source) as source_varchar,
@source as source_binary,
@encoded as encoded,
@decoded as decoded_binary,
convert(varchar(max), @decoded) as decoded_varchar

/* Decrypt a Base 64 string */
SELECT 
    CONVERT
    (
        VARCHAR(MAX), 
        CAST('' AS XML).value('xs:base64Binary(sql:column("BASE64_COLUMN"))', 'VARBINARY(MAX)')
    ) AS RESULT
FROM
    (
        SELECT 'xxx' AS BASE64_COLUMN
    ) A


/* Run a query against multiple databases */
DECLARE 
    @DBName VARCHAR(100), 
@sql NVARCHAR(MAX);

DECLARE cursor_dbs CURSOR
FOR SELECT [Name] FROM sys.databases 
WHERE [Name] LIKE 'DWData%' 
ORDER BY 1;

OPEN cursor_dbs;

FETCH NEXT FROM cursor_dbs INTO @DBName;

WHILE @@FETCH_STATUS = 0
    BEGIN

SET @sql = 'USE ' + @DBName + '; select ''' + @DBName + ''' AS DBName, * from masterfacilities where masterfacilityid < 0'
--PRINT @sql;
EXEC sp_executesql @sql;
        
        FETCH NEXT FROM cursor_dbs INTO @DBName;
    END;

CLOSE cursor_dbs;

DEALLOCATE cursor_dbs;

/* Loop through all DBs to execute a set of queries */
EXECUTE master.sys.sp_MSforeachdb 
'USE [?]; 
if db_name(db_id()) LIKE ''DWStaging%'' 
Begin 
--query goes here
end'



/**************************************************************************************************************************************************/
/* Loop through specific databases and identify which ones contain a specific table */
SET NOCOUNT ON;
DECLARE @sql NVARCHAR(MAX)

--Drop the temp table if it already exists
DROP TABLE IF EXISTS #Temp;

--Create the temp table
CREATE TABLE #temp
(
        DatabaseName NVARCHAR(MAX),
        TableName NVARCHAR(MAX),
        ColumnName NVARCHAR(MAX)
)

--Query to get your DB/table/column info
SET @sql = 'USE ? 
SELECT 
TABLE_CATALOG, 
TABLE_NAME,
COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_CATALOG LIKE ''DW%''
ORDER BY TABLE_CATALOG, TABLE_NAME, ORDINAL_POSITION'

--Insert the output of the loop into the temp table
INSERT INTO #temp(DatabaseName, TableName, ColumnName)
EXEC sp_MSforeachdb @sql;

--Output the results
SELECT * FROM #temp

--Drop the temp table if it still exists
DROP TABLE IF EXISTS #Temp;



/**************************************************************************************************************************************************/
/* Cursor through the records in a SQL query */
DECLARE 
    @CursorField VARCHAR(100), 
    @sql NVARCHAR(MAX);

DECLARE cursor1 CURSOR
FOR 
--QUERY TO CURSOR THROUGH
SELECT [Name] 
FROM sys.databases 
WHERE [Name] LIKE 'DW%' 
ORDER BY 1;

OPEN cursor1;
FETCH NEXT FROM cursor1 INTO @CursorField;

WHILE @@FETCH_STATUS = 0
    BEGIN

        SET @sql = 'SQL QUERY';
        --PRINT @sql;
        EXEC sp_executesql @sql;
        
    FETCH NEXT FROM cursor1 INTO @CursorField;

    END;

CLOSE cursor1;
DEALLOCATE cursor1;


/**************************************************************************************************************************************************/
/* Identify all the tables that contain a specific field, and then bring back any records for a particular value (i.e. find all tables that contain data for a specific patient */

--Use this to generate the SELECT statements for the tables that contain the field you are looking for
SELECT 'SELECT ''' + so.name + ''' AS TableName, ''' + sc.name + ''' AS ColumnName, COUNT(*) as cnt FROM ' + so.name + ' WHERE ' + sc.Name + ' = 123456 UNION '
FROM sysobjects so
JOIN syscolumns sc ON sc.id = so.id
        AND so.xtype = 'U'
JOIN sys.objects o ON so.name = o.name
        AND SCHEMA_NAME(o.schema_id) = 'dbo'
WHERE sc.name = 'pid'
ORDER BY 1

--Now take that output and query those tables to bring back the instances where those tables contained data for our patient
;With p AS
(
        SELECT 'Allergies' AS TableName, 'patid' AS ColumnName, COUNT(*) as cnt FROM AM_vt_Allergies WHERE uid = 123456 UNION 
        SELECT 'contacts' AS TableName, 'patid' AS ColumnName, COUNT(*) as cnt FROM AM_vt_contacts WHERE pid = 123456 UNION 
        SELECT 'diagnosis' AS TableName, 'patid' AS ColumnName, COUNT(*) as cnt FROM AM_vt_diagnosis WHERE uid = 123456 
)
SELECT 'SELECT * FROM ' + TableName + ' WHERE ' + ColumnName + ' = 123456'
FROM p WHERE cnt > 0 
ORDER BY 1

--Now scan through the tables that brought back record counts above to look for any important data/fields
SELECT * FROM allergies WHERE patid = 123456
SELECT * FROM contacts WHERE patid = 123456
SELECT * FROM diagnosis WHERE patid = 123456


/**************************************************************************************************************************************************/
/* Unpivot a field */
--Example record:
SELECT PAT_ID, PAT_ENC_CSN_ID, TOBACCO_PAK_PER_DY,TOBACCO_USED_YEARS,SMOKING_QUIT_DATE,CIGARETTES_YN
FROM SocHX

--How to unpivot:
SELECT PAT_ID, PAT_ENC_CSN_ID, u.column_name, u.value
FROM SocHX
UNPIVOT
(
  value
  FOR column_name IN (TOBACCO_PAK_PER_DY,TOBACCO_USED_YEARS,SMOKING_QUIT_DATE,CIGARETTES_YN)
) u


/**************************************************************************************************************************************************/
/* Pivot 
 https://www.sqlservertutorial.net/sql-server-basics/sql-server-pivot/
*/
SELECT 
        'Catalyst - Patient Attributions (High Volume Payers)' AS DataType,
        MonthYear, 
        FORMAT([Catalyst Aetna],'#,#0') AS [Aetna],
        FORMAT([Catalyst Blue Cross Blue Shield],'#,#0') AS [BCBS],
        FORMAT([East Texas BCBS],'#,#0') AS [Strive BCBS],
        FORMAT([Catalyst Cigna],'#,#0') AS [Cigna],
        FORMAT([Catalyst United],'#,#0') AS [United]
FROM  
(
        SELECT 
                ds.[Name] AS DataSourceName,
                d.MonthYear,
                pa.PatientAttributionID
        FROM [dbo].[PatientAttributions] pa WITH (NOLOCK)
        JOIN [DwKernel].dbo.DataSources ds WITH (NOLOCK) ON ds.DataSourceID = pa.DataSourceID
                AND ds.DataWarehouseDatabase LIKE 'DWDataPopulationHealth%'
        FULL OUTER JOIN [DWKernel].[dbo].[Dates] d WITH (NOLOCK) ON d.date = pa.AttributionBeginDate
        WHERE YEAR(d.[Date]) IN(2020)
) AS src  
PIVOT  
(  
        COUNT(PatientAttributionID)
        FOR DataSourceName IN (
                [Catalyst Aetna],
                [Catalyst Blue Cross Blue Shield],
                [East Texas BCBS],
                [Catalyst Cigna],
                [Catalyst United])  
) AS piv  
ORDER BY CAST(MonthYear AS DATE)


/**************************************************************************************************************************************************/
/* What are the top x used codes for each codeset? */
WITH medhx AS
(
        SELECT 
        source_id, 
        patient_hx_type, 
        patient_hx_codeset, 
        patient_hx_code, 
        patient_hx_description, 
        COUNT(DISTINCT record_id) AS cnt, 
        RANK() OVER (PARTITION BY source_id, patient_hx_type, patient_hx_codeset ORDER BY COUNT(*) DESC) AS coderank
        FROM PATIENT_HX
        WHERE patient_hx_type = 'Medical'
        GROUP BY source_id, patient_hx_type, patient_hx_codeset, patient_hx_code, patient_hx_description
        ORDER BY 1,2,3,6 DESC
)
SELECT source_id, patient_hx_type, patient_hx_codeset, patient_hx_code, patient_hx_description, cnt, coderank
FROM medhx
WHERE coderank <= 10
ORDER BY source_id, patient_hx_type, patient_hx_codeset,coderank


/**************************************************************************************************************************************************/
/* Parse a delimited list of values from a field using XML */
IF OBJECT_ID('tempdb..#Temp') IS NOT NULL DROP TABLE #Temp;
CREATE TABLE #Temp
(
    SomeID INT,
    MedCodes VARCHAR(MAX)
)

--Insert test cases
INSERT #Temp SELECT 1654654, 'MELOXICAM (Generic dispensed) |NITROFURANTOIN MONO-MACRO (Generic dispensed) |PREDNISONE (Generic dispensed) |SERTRALINE HCL (Generic dispensed) |SILENOR (Brand (Generic Available))'
INSERT #Temp SELECT 4859866, 'AMOXICILLIN (Generic dispensed)'
INSERT #Temp SELECT 1654333, 'CLOPIDOGREL (Generic dispensed) |ESZOPICLONE (Generic dispensed) |GLIPIZIDE (Generic dispensed) |INVOKAMET (Brand dispensed (no Generic available)) |ROSUVASTATIN CALCIUM (Generic dispensed) |RYBELSUS (Brand dispensed (no Generic available))'
INSERT #Temp SELECT 1629283, 'BAD XML & BADDER XML'
INSERT #Temp SELECT 6334887, 'SOME EVEN WORSE < XML >'

--Parse as XML
SELECT 
*
,(SELECT MedCodes AS [data()] FOR XML PATH('')) AS ConvertReservedXML
,CAST ('<Y>' + REPLACE((SELECT MedCodes AS [data()] FOR XML PATH('')) , '|', '</Y><Y>') + '</Y>' AS XML) AS SplitPipes
FROM #Temp

--Unpivot values based on a pipe delimiter
 SELECT 
y.SomeID  
    ,s.y.value('.', 'VARCHAR(100)') AS Data  
 FROM  
 (
     SELECT 
SomeID  
,CAST ('<Y>' + REPLACE((SELECT MedCodes AS [data()] FOR XML PATH('')) , '|', '</Y><Y>') + '</Y>' AS XML) AS Data
     FROM #Temp
 ) AS y 
 CROSS APPLY Data.nodes ('/Y') AS s(y); 
 

 IF OBJECT_ID('tempdb..#Temp') IS NOT NULL DROP TABLE #Temp;
