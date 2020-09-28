-- Tests whether or not function is already defined as an object
IF OBJECT_ID('dbo.F_TRANSLATE_BEHAVIOR', 'FN') IS NOT NULL
		
	-- Drops the function if already defined	
	DROP FUNCTION dbo.F_TRANSLATE_BEHAVIOR;

-- End of first batch block
GO

-- Defines a function that uses the name of the column and the corresponding code to translate the SIS 
-- Based code values into numeric values to be used in Stata
CREATE FUNCTION dbo.F_TRANSLATE_BEHAVIOR(@colnm VARCHAR(24), @code VARCHAR(15))

	-- Defines what type scalar is returned by the function
	RETURNS TINYINT AS

	-- Starts the function body
	BEGIN

		-- Declares a variable to be used to store the return value
		DECLARE @retval TINYINT;

		-- Sets the value of the variable
		SET @retval = (	SELECT a.stcode
						FROM dbo.behaviorLookups AS a
						WHERE a.varnm = @colnm AND a.siscode = @code);
		
		-- Returns the variable
		RETURN(@retval);

	-- End of the function body	
	END

-- End of final batch block	
GO

-- Example case.  Should return a value of 4
SELECT dbo.F_TRANSLATE_BEHAVIOR('boardViolation', '1004');


-- Example case.  Should return a value of 17
SELECT dbo.F_TRANSLATE_BEHAVIOR('lawViolation', '1811');
