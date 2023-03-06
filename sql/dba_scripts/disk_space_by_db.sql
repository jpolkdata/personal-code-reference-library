/***
	Get the total available and total used space on this server
***/
SELECT  
	SERVERPROPERTY('MachineName') as HostName
	,volume_mount_point
	,FORMAT(max(total_bytes / 1048576.0) / 1024,'#,##0.00') as TotalSize_Gb
	,FORMAT(max(available_bytes / 1048576.0) / 1024,'#,##0.00') as Avalable_Size_Gb 
FROM sys.master_files AS f  
CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id)
GROUP BY volume_mount_point

/*** 
	Calculate the total size of all DBs on this server 
***/
SELECT 
	FORMAT(SUM (CASE WHEN type_desc = 'ROWS' THEN ((size * 8) / 1024.0)/1024 end) +
		SUM (CASE WHEN type_desc = 'LOG' THEN ((size * 8) / 1024.0)/1024 end),'#,##0.00') as Total_Size_GB
FROM sys.master_files

/***
	Get a breakdown of the space used per database
***/
SELECT 
	DB_NAME(database_id) as DBName 
	,FORMAT(SUM (CASE WHEN type_desc = 'ROWS' THEN ((size * 8) / 1024.0)/1024 end),'#,##0.00') as Data_Size_GB
	,FORMAT(SUM (CASE WHEN type_desc = 'LOG' THEN ((size * 8) / 1024.0)/1024 end),'#,##0.00') as Log_Size_GB
	,FORMAT(SUM (CASE WHEN type_desc = 'ROWS' THEN ((size * 8) / 1024.0)/1024 end) +
		SUM(CASE WHEN type_desc = 'LOG' THEN ((size * 8) / 1024.0)/1024 end),'#,##0.00') as Total_Size_GB
FROM sys.master_files
GROUP BY database_id
ORDER BY 1
