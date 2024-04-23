/*** 
    Add a dynamic rowhash to a table 

    NOTES:
        - SHA1 hashbytes value has a max length of 40 when converted to VARCHAR

        - When you convert the hashbytes (hex) value to a varchar, you lose the '0x' that 
            would precede the value, so it should be re-added if you want that same format

        - If you want your rowhash to be case-insensitive, you should UPPER the varchar 
            values within the hashbytes statement

        - You want to add a separator character between the columns to allow for empty strings.
            If you don't do this, the following records are considered the same:
                'One',",'Another'
                'One','Another,"
***/

CREATE TABLE [dbo].[TestData](
    --Primary Key
	[ID] INT IDENTITY(1,1) NOT NULL,

    --Source Data
	[SourceID] INT NOT NULL,
	[Description] VARCHAR(100) NOT NULL,
	[Type] VARCHAR(25) NULL,
	[CreateDateTime] DATETIME NULL,
	[UpdateDateTime] DATETIME NULL,
	[DeleteDateTime] DATETIME NULL,

    --ETL Metadata
	[BatchID] VARCHAR(40) NOT NULL,
	[DataSourceID] INT NOT NULL,
	[LoadCreateDateTime] DATETIME NOT NULL DEFAULT GETDATE(),
	[LoadUpdateDateTime] DATETIME NULL,

	[RowHash] AS
	(
		CONCAT(
			'0x', --When we convert to VARCHAR we lose the '0x' that precedes the rowhash (indicating it is a hex value); manually re-add this
			CONVERT
			(
				VARCHAR(40), --a SHA1 hashbytes has a fixed length of 40 hex characters
				(
					HASHBYTES --Create a SHA1 hash of all the data points in this table that might change due to source data changes
					(
						'SHA1', 
						CONCAT
						(
							CONVERT(VARCHAR(11), COALESCE([SourceID],'')), --A 32-bit integer can be no larger than 11 characters
                            '|',
							CONVERT(VARCHAR(100), COALESCE([Description],'')),
                            '|',
							CONVERT(VARCHAR(25), COALESCE([Type],'')),
                            '|',
							CONVERT(VARCHAR(17), COALESCE(FORMAT([Created],'yyyyMMdd HH:mm:ss'),'')),
                            '|',
							CONVERT(VARCHAR(17), COALESCE(FORMAT([Modified],'yyyyMMdd HH:mm:ss'),'')),
                            '|',
							CONVERT(VARCHAR(17), COALESCE(FORMAT([Deleted],'yyyyMMdd HH:mm:ss'),''))
						)
					)
				)
				,2
			)
		)
	),
 CONSTRAINT [PK_TestData] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]