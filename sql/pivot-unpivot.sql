
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
DROP TABLE IF EXISTS #pat_phones;
CREATE TABLE #pat_phones
(
	patient_id INT
	,number VARCHAR(10)
	,phonetype VARCHAR(25)
)

INSERT INTO #pat_phones(patient_id,number,phonetype) VALUES(11111,'1234567890','Mobile')
INSERT INTO #pat_phones(patient_id,number,phonetype) VALUES(22222,'4444444444','Mobile')
INSERT INTO #pat_phones(patient_id,number,phonetype) VALUES(22222,'1111111111','Home')
INSERT INTO #pat_phones(patient_id,number,phonetype) VALUES(22222,'2222222222','Work')
INSERT INTO #pat_phones(patient_id,number,phonetype) VALUES(22222,'3333333333','Main')
INSERT INTO #pat_phones(patient_id,number,phonetype) VALUES(33333,'4445558888','Main')

SELECT
	'Patient Phone Numbers' AS Detail
	,patient_id
	,[Home]
	,[Mobile]
	,[Main]
	,[Work]
FROM (
	SELECT patient_id, number, phonetype
	FROM #pat_phones
	WHERE phonetype IN('Home','Mobile','Main','Work')
) src
PIVOT
(
	MAX(number)
	FOR phonetype IN([Home],[Mobile],[Main],[Work])
) AS piv
ORDER BY patient_id;

DROP TABLE IF EXISTS #pat_phones;
