/***
	Run a delete command in smaller batches. This is useful when attemtping to delete specific records
	from a very large table, where running one command for all of the deletes would take a very long time
	and potentially lock up the table.

	There are two things you want to make sure you adjust below:
		- The TABLE_NAME should be replaced with your DB table name
		- The DELETE_CRITERIA in the WHERE clause should be defined. If you do not need this, then you
			would likely be better off TRUNCATING the table anyways.
***/
SET NOCOUNT ON

--Get the current count of records in the table that match our criteria
DECLARE @total INT = (SELECT COUNT(1) FROM TABLE_NAME (NOLOCK) WHERE DELETE_CRITERIA);
PRINT CONCAT('Total remaining: ',CAST(@total AS VARCHAR(10)));

--Calculate the number of iterations we will need in the loop based on a batch size of 5k records
DECLARE @BatchCount INT = CEILING(@total / 5000.00)

--Now iterate for as many times as we determined that we have batches above
DECLARE @i INT = 1;
WHILE (@i <= @BatchCount)
BEGIN
    BEGIN TRAN d;

	--Define the delete criteria, but only delete 5k records at a time
    DELETE TOP (5000) FROM TABLE_NAME WHERE DELETE_CRITERIA;

    PRINT CONCAT('Iteration: ',CAST(@i AS VARCHAR(10)),'; Records: ',@@ROWCOUNT);
	SET @i = @i+1;

    COMMIT TRAN d;
END;

--Print out a status check so we know how much work is left to do
SET @total = (SELECT COUNT(1) FROM TABLE_NAME (NOLOCK) WHERE DELETE_CRITERIA);
PRINT CONCAT('Total remaining: ',CAST(@total AS VARCHAR(10)));
