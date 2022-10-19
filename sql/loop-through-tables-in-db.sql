
/**************************************************************************************************************************************************
    Identify all the tables that contain a specific field, and then bring back any records where that field matches a particular value 
    (i.e. Identify all tables that contain data for a specific patient id)
**************************************************************************************************************************************************/

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
--NOTE: you'll need to paste the results of the query above into the CTE below. This could be better automated.
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
--NOTE: Again this is a manual copy/paste from the query above, ideally we run all 3 commands in one go
SELECT * FROM allergies WHERE patid = 123456
SELECT * FROM contacts WHERE patid = 123456
SELECT * FROM diagnosis WHERE patid = 123456