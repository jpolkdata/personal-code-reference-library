/*
	Resources for troubleshooting potential SQL server slowness
		https://sqlserverplanet.com/troubleshooting/sql-server-slowness
*/
DECLARE @temp TABLE  
(
	 SPID INT
	,[Status] VARCHAR(50)
	,[Login] VARCHAR(100)
	,HostName VARCHAR(100)
	,BlkBy VARCHAR(100)
	,DBName VARCHAR(100)
	,Command VARCHAR(100)
	,CPUTime BIGINT
	,DiskIO BIGINT
	,LastBatch VARCHAR(100)
	,ProgramName VARCHAR(100)
	,SPID2 INT
	,RequestID INT
)

INSERT INTO @temp
EXEC sp_who2 

--Are any processes being blocked?
SELECT 'Blocked processes' AS Detail, * 
FROM @temp 
WHERE BlkBy <> '  .'

--If you find any blocked processes, you can use DBCC INPUTBUFFER to find the last statement executed by individual SPIDs (https://sqlserverplanet.com/dba/using-dbcc-inputbuffer)
--DBCC INPUTBUFFER(440)

/*
	High CPUTime or High DiskIO time is usually spotted by comparing the relative CPUTime to the DiskIO time. 
	It should be noted that CPUTime and DiskIO time represent the sum of all executions since the SPID has been active. 
	It may take some training before you are able to spot a high number here. At times, you will see very high 
	CPUTimes and almost no corresponding DiskIO. This is usually indicative of a bad execution plan.
*/
SELECT 'High CPUTime' AS Detail, * 
FROM @temp 
WHERE SPID > 50 --1-50 are system SPIDs, user SPIDs start after 50
AND CPUTime > 0 
ORDER BY CPUTime DESC

SELECT 'High DiskIO' AS Detail, * 
FROM @temp 
WHERE SPID > 50 --1-50 are system SPIDs, user SPIDs start after 50
AND DiskIO > 0 
ORDER BY DiskIO DESC


