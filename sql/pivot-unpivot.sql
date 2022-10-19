
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
    'Patient Attributions Per Payer' AS DataType,
    MonthYear, 
    FORMAT([Aetna],'#,#0') AS [Aetna],
    FORMAT([Blue Cross Blue Shield],'#,#0') AS [BCBS],
    FORMAT([East Texas BCBS],'#,#0') AS [Strive BCBS],
    FORMAT([Cigna],'#,#0') AS [Cigna],
    FORMAT([United],'#,#0') AS [United]
FROM  
(
    SELECT 
        ds.[Name] AS DataSourceName
        ,d.MonthYear
        ,pa.PatientAttributionID
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
        [Aetna]
        ,[Blue Cross Blue Shield]
        ,[East Texas BCBS]
        ,[Cigna]
        ,[United])  
) AS piv  
ORDER BY CAST(MonthYear AS DATE)
