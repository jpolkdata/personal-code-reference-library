
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



/**************************************************************************************************************************************************
    Unpivot a column
**************************************************************************************************************************************************/
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


/**************************************************************************************************************************************************
    Pivot a column
    https://www.sqlservertutorial.net/sql-server-basics/sql-server-pivot/
**************************************************************************************************************************************************/
SELECT 
        'Patient Attributions (High Volume Payers)' AS DataType,
        MonthYear, 
        FORMAT([Aetna],'#,#0') AS [Aetna],
        FORMAT([Blue Cross Blue Shield],'#,#0') AS [BCBS],
        FORMAT([East Texas BCBS],'#,#0') AS [Strive BCBS],
        FORMAT([Cigna],'#,#0') AS [Cigna],
        FORMAT([United],'#,#0') AS [United]
FROM  
(
        SELECT 
                ds.[Name] AS DataSourceName,
                d.MonthYear,
                pa.PatientAttributionID
        FROM [dbo].[PatientAttributions] pa WITH (NOLOCK)
        JOIN [DwKernel].dbo.DataSources ds WITH (NOLOCK) ON ds.DataSourceID = pa.DataSourceID
                AND ds.DataWarehouseDatabase LIKE 'DW%'
        FULL OUTER JOIN [DWKernel].[dbo].[Dates] d WITH (NOLOCK) ON d.date = pa.AttributionBeginDate
        WHERE YEAR(d.[Date]) IN(2020)
) AS src  
PIVOT  
(  
        COUNT(PatientAttributionID)
        FOR DataSourceName IN (
                [Aetna],
                [Blue Cross Blue Shield],
                [East Texas BCBS],
                [Cigna],
                [United])  
) AS piv  
ORDER BY CAST(MonthYear AS DATE)


/**************************************************************************************************************************************************
    What are the top x used codes for each codeset?
**************************************************************************************************************************************************/
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


