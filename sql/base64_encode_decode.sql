
/**************************************************************************************************************************************************
    Encode a string into Base64 and then decode it back into its original value
**************************************************************************************************************************************************/
DECLARE @user VARCHAR(255)	= 'Username'; --CHANGEME
DECLARE @pw	VARCHAR(255)	= 'Password'; --CHANGEME

--Combine the username and password into a string in the format "{USERNAME}:{PASSWORD}"
DECLARE @encodeString VARCHAR(MAX) = CONCAT(@user,':',@pw);

--Encode the username and password into a Base64 string
DECLARE @Base64String VARCHAR(MAX) = ''
SET @Base64String = 
(
	SELECT
		CAST(N'' AS XML).value(
			  'xs:base64Binary(xs:hexBinary(sql:column("bin")))'
			, 'VARCHAR(MAX)'
		)   Base64Encoding
	FROM (
		SELECT CAST(@encodeString AS VARBINARY(MAX)) AS bin
	) AS bin_sql_server_temp
);

-- Add in the extra info needed so that it can just be copy and pasted into the ADF piepeline
SELECT CONCAT('Authorization: Basic ',@Base64String) AS ADFPipelineHeader;

-- Decode the Base64-encoded string, you should get back the original user and password
DECLARE @DecodedString AS VARCHAR(MAX) = 
(
	SELECT 
		CAST(
			CAST(N'' AS XML).value(
			'xs:base64Binary("VXNlcm5hbWU6UGFzc3dvcmQ=")' 
			  , 'VARBINARY(MAX)'
			) 
			AS VARCHAR(MAX)
		)   
);

--Split string back out into user and password for verification of the process
SELECT LEFT(@DecodedString,CHARINDEX(':',@DecodedString)-1) AS DecodedUserName;
SELECT RIGHT(@DecodedString,CHARINDEX(':',@DecodedString)-1) AS DecodedPW;

