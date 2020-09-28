-- Tests whether the function is currently built on the data base
IF object_id(N'dbo.F_GET_DIRECTOR', N'FN') IS NOT NULL

	-- If the function exists drop it before redefining it
    DROP FUNCTION dbo.F_GET_DIRECTOR;

-- End of batch block
GO

-- Defines a function used to look up school directors based on 
-- either the school ID or the school name
CREATE FUNCTION dbo.F_GET_DIRECTOR(@school VARCHAR(50))

  -- Returns the name of the school director
	RETURNS VARCHAR(50) AS

  -- Starts the function body
	BEGIN

    -- Declares the variable used to store the director's name
		DECLARE @theDirector VARCHAR(50);

    -- Sets the value of the variable by looking it up in the directors table
		SET @theDirector =
			(SELECT dirnm
			FROM dbo.directors
			WHERE schid = @school OR schnm = @school);

    -- Returns the name of the school director
		RETURN(@theDirector);

  -- End of the function body
	END;

-- End of the batch 
GO

-- Example with school ID passed as the parameter.  
-- Should return 'Heather Bell'
SELECT dbo.F_GET_DIRECTOR('037');

-- Example with school name passed as the parameter.
-- Should return 'Jack Hayes' 
SELECT dbo.F_GET_DIRECTOR('Martin L King Acad for Excellence Alt');

