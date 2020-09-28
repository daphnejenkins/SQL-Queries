-- Check if function is already defined
IF OBJECT_ID('dbo.F_KPREP_TO_Z', 'FN') IS NOT NULL
	    
    -- Drop the function from the server
    DROP FUNCTION dbo.F_KPREP_TO_Z;

GO

-- Defines function to create Z-Scores from kprep
CREATE FUNCTION F_KPREP_TO_Z(@schyr INT, @grade TINYINT, @subj VARCHAR(3), @score DOUBLE PRECISION)

  -- Declares the return type of the function
  RETURNS DOUBLE PRECISION AS

  -- Starts the function body
  BEGIN

    -- Defines the variable that will store the return value
    DECLARE @retval DOUBLE PRECISION;

    -- Demean the passed value and divide by standard deviation
    SET @retval = (SELECT (@score - ks.mu) / ks.sigma
	           FROM kprepStandardization AS ks
		   WHERE ks.schyr = @schyr AND 
		         ks.grade = @grade AND 
		         ks.subject = @subj);

    -- Returns the z-score transformed data
    RETURN(@retval);

  -- End of the function body
  END

-- End of this batch
GO

-- Test case should return a value of 1
SELECT dbo.F_KPREP_TO_Z(2016, 3, 'rdg', 230.36);

