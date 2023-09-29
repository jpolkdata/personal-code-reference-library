/*** Add a rowhash to a table ***/
CREATE TABLE [dbo].[TestData]
(
    ID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(255),
    Price DECIMAL(10,2),
    Quantity INT,

	/*
	SHA2_512 has a length of 64. If you don't convert it to BINARY(64) the 
	resulting data type will be VARBINARY(8000)

	Uppercasing the value ensures that the row hash will not be case sensitive

    You want to add a separator character between columns to allow for empty strings.
    If you don't do this, the following records are considered the same:
        'One',",'Another'
        'One','Another,"
	*/
    RowHash AS CONVERT(BINARY(64), hashbytes('SHA2_512', CONCAT(
												UPPER(COALESCE(Name, '')), '|'
                                                , COALESCE(CONVERT(VARCHAR(50), Price), ''), '|'
                                                , COALESCE(CONVERT(VARCHAR(20), Quantity), ''), '|'
                                                ))) persisted
) 
