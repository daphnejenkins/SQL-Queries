/*******************************************************************************
*                                                                              *
* Defines a function used to return a DATETIME value when passed a Stata       *
* %tc formatted datetime value stored in a database.  This makes provides an   *
* in database method for translating these values into something meaningful to * 
* the database.                                                                *
*                                                                              *
*******************************************************************************/

-- Test to see if the function is already defined in the database
IF OBJECT_ID('dbo.F_FLOAT_TO_DATETIME', 'FN') IS NOT NULL

	-- If the function already exists, drop it
	DROP FUNCTION dbo.F_FLOAT_TO_DATETIME;
	
-- End of first batch block	
GO

/*
Defines a function to convert a Stata datetime value to a SQL Server DATETIME 
type in the database.  The sole argument to the function is the value of the 
floating point number Stata uses to represent datetime values.
*/
CREATE FUNCTION dbo.F_FLOAT_TO_DATETIME(@statatc FLOAT) 

	-- Defines the casting of the return type
	RETURNS DATETIME
	
	AS
	
	-- Starts function body
	BEGIN
	
		-- Declares the variable that will store the result
		DECLARE @theDateValue DATETIME;
		
		-- Sets the result
		SET @theDateValue = 
		DATEADD(ss, CAST(FLOOR(@statatc) AS BIGINT)/1000 + 8*60*60, '1/1/1960');
		
		-- Returns the resulting date time
		RETURN(@theDateValue)
		
	-- End of the function body	
	END
	
-- End of the final batch block	
GO
