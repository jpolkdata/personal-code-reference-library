/***
  Get info on the database log sizes for each DB on the server
***/
DECLARE @temp TABLE
(
	 DatabaseName VARCHAR(100)
	,LogSizeMB DECIMAL(18,2)
	,LogSpaceUsed DECIMAL(18,2)
	,[Status] INT
)

INSERT INTO @temp
EXEC('DBCC SQLPERF(LOGSPACE);')

SELECT 
	 DataBaseName
	,FORMAT(LogSizeMB,'#,##0.00') AS LogSizeMB
	,LogSpaceUsed
	,[Status]
FROM @temp
ORDER BY CAST(LogSizeMB AS DECIMAL(18,2)) DESC

DBCC loginfo