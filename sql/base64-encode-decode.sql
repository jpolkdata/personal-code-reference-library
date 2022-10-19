
/**************************************************************************************************************************************************
    Encrypt and decrypt a Base64 string
**************************************************************************************************************************************************/
--Encode the string "TestData" in Base64 to get "VGVzdERhdGE="
SELECT
    CAST(N'' AS XML).value(
        'xs:base64Binary(xs:hexBinary(sql:column("bin")))'
        , 'VARCHAR(MAX)'
    )   Base64Encoding
FROM (SELECT CAST('TestData' AS VARBINARY(MAX)) AS bin) AS bin_sql_server_temp;

--Decode the Base64-encoded string "VGVzdERhdGE=" to get back "TestData"
SELECT 
    CAST(
        CAST(N'' AS XML).value(
            'xs:base64Binary("VGVzdERhdGE=")'
          , 'VARBINARY(MAX)'
        ) 
        AS VARCHAR(MAX)
    )   ASCIIEncoding
;
