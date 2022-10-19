/**************************************************************************************************************************************************
	Queries below from the article https://www.sqlshack.com/gathering-sql-server-indexes-statistics-and-usage-information/
**************************************************************************************************************************************************/

--Get index details
SELECT  
	Tab.name AS Table_Name 
	,IX.name AS Index_Name
	,IX.type_desc AS Index_Type
	,Col.name AS Index_Column_Name
	,IXC.is_included_column AS Is_Included_Column
	,IX.fill_factor 
	,IX.is_disabled
	,IX.is_primary_key
	,IX.is_unique		 		  
FROM sys.indexes IX 
INNER JOIN sys.index_columns IXC ON IX.object_id = IXC.object_id AND IX.index_id = IXC.index_id 
INNER JOIN sys.columns Col ON IX.object_id = Col.object_id AND IXC.column_id = Col.column_id 
INNER JOIN sys.tables Tab ON IX.object_id = Tab.object_id
--WHERE IX.name LIKE '%IX%'
ORDER BY 1, 2

--Get fragmentation
SELECT
	OBJECT_NAME(IDX.OBJECT_ID) AS Table_Name
	,IDX.name AS Index_Name
	,IDXPS.index_type_desc AS Index_Typ
	,IDXPS.avg_fragmentation_in_percent AS Fragmentation_Percentage
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) IDXPS 
INNER JOIN sys.indexes IDX  ON IDX.object_id = IDXPS.object_id 
AND IDX.index_id = IDXPS.index_id 
ORDER BY Fragmentation_Percentage DESC

--Get cumulative info for indexes (since the last SQL server restart)
SELECT 
	OBJECT_NAME(IX.OBJECT_ID) Table_Name
	,IX.name AS Index_Name
	,IX.type_desc AS Index_Type
	,SUM(PS.[used_page_count]) * 8 AS IndexSizeKB
	,IXUS.user_seeks AS NumOfSeeks
	,IXUS.user_scans AS NumOfScans
	,IXUS.user_lookups AS NumOfLookups
	,IXUS.user_updates AS NumOfUpdates
	,IXUS.last_user_seek AS LastSeek
	,IXUS.last_user_scan AS LastScan
	,IXUS.last_user_lookup AS LastLookup
	,IXUS.last_user_update AS LastUpdate
FROM sys.indexes IX
INNER JOIN sys.dm_db_index_usage_stats IXUS ON IXUS.index_id = IX.index_id AND IXUS.OBJECT_ID = IX.OBJECT_ID
INNER JOIN sys.dm_db_partition_stats PS on PS.object_id=IX.object_id
WHERE OBJECTPROPERTY(IX.OBJECT_ID,'IsUserTable') = 1
AND IX.name LIKE '%BCBS%'
GROUP BY OBJECT_NAME(IX.OBJECT_ID) ,IX.name ,IX.type_desc ,IXUS.user_seeks ,IXUS.user_scans ,IXUS.user_lookups,IXUS.user_updates ,IXUS.last_user_seek ,IXUS.last_user_scan ,IXUS.last_user_lookup ,IXUS.last_user_update
ORDER BY 1, 2

--Get stats on the I/O operations done
SELECT 
	OBJECT_NAME(IXOS.OBJECT_ID) AS Table_Name 
	,IX.name AS Index_Name
	,IX.type_desc AS Index_Type
	,SUM(PS.[used_page_count]) * 8 AS IndexSizeKB
	,IXOS.LEAF_INSERT_COUNT AS NumOfInserts
	,IXOS.LEAF_UPDATE_COUNT AS NumOfupdates
	,IXOS.LEAF_DELETE_COUNT AS NumOfDeletes   
FROM SYS.DM_DB_INDEX_OPERATIONAL_STATS (NULL,NULL,NULL,NULL ) IXOS 
INNER JOIN SYS.INDEXES AS IX ON IX.OBJECT_ID = IXOS.OBJECT_ID AND IX.INDEX_ID = IXOS.INDEX_ID 
INNER JOIN sys.dm_db_partition_stats PS on PS.object_id=IX.object_id
WHERE  OBJECTPROPERTY(IX.[OBJECT_ID],'IsUserTable') = 1
AND IX.name LIKE '%BCBS%'
GROUP BY OBJECT_NAME(IXOS.OBJECT_ID), IX.name, IX.type_desc,IXOS.LEAF_INSERT_COUNT, IXOS.LEAF_UPDATE_COUNT,IXOS.LEAF_DELETE_COUNT
