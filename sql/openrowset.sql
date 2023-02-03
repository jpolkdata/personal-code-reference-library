/*
Using a predefined format file, OPENROWSET can be leveraged to query a flat file as if it
is a SQL table. This can be used to analyze raw files as well as import them into DB tables.

More Info:
  https://learn.microsoft.com/en-us/sql/t-sql/functions/openrowset-transact-sql
*/

/***
  If you have the raw files and format file locally, you can leverage a local SQL instance
  to query the file.
***/
SELECT TOP 100 *
FROM OPENROWSET(BULK N'C:\TestFiles\Patients.csv'
    ,FORMATFILE = N'C:\TestFiles\Patients.xml'
    ,FIRSTROW = 2 --Skip the header
    ,FORMAT='CSV') x

/***
  This process can also be leveraged for a SQL managed instance inside Azure. You would
  just need to configure external resources that point to the location where both the
  raw files and format files are stored.
***/
SELECT TOP 100 *
FROM OPENROWSET(
	 BULK 'TestFiles/Patients.csv'
	,DATA_SOURCE = 'DSRawDataStorage' --Under the "External Resources", configured to point to the blob storage container with the file
	,FORMATFILE = 'Format/Patients.xml'
	,FORMATFILE_DATA_SOURCE = 'DSFormatFileStorage' --Under the "External Resources", configured to point to the blob storage container with the format file
	,FIRSTROW = 2
	,CODEPAGE = 'RAW'
) AS x
