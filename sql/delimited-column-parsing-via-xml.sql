/**************************************************************************************************************************************************
    Parse a delimited list of values from an individual column by leveraging XML

    This example references a column that contains multiple values stored within a medication column. 
    The values are delimited by a vertical pipe.
**************************************************************************************************************************************************/
DROP TABLE IF EXISTS #Temp;
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
 
DROP TABLE IF EXISTS #Temp;
