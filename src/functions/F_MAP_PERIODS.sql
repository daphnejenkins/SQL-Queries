/*

    Generates a lookup table containing period IDs and corresponding test dates
    Periods :
        1 = FALL
        2 = WINTER
        3 = SPRING

    Example:  
    
    SELECT a.*
    FROM dbo.F_MAP_PERIODS(2015) AS a;
    
    RETURNS : 
    schyr   | period |    testdate  
    2015    |   1    |   2014-09-25
    2015    |   2    |   2015-01-25
    2015    |   3    |   2015-05-25


*/

-- Drops the function if it is already defined in the database/schema
IF object_id('F_MAP_PERIODS', 'TF') IS NOT NULL
	    DROP FUNCTION [dbo].F_MAP_PERIODS;
	GO

	-- Defines the function F_SAT_BENCHMARKS
CREATE FUNCTION dbo.F_MAP_PERIODS(@schyr INT)

  -- Declares what will be returned by the function
  RETURNS @returnValue TABLE (
	    schyr INT,
	    period TINYINT,
	    testdate DATE
	  ) AS

	  -- Begins the body of the function
  BEGIN

	    INSERT @returnValue (schyr, period, testdate)
	    SELECT DISTINCT a.schyr,
	                    ROW_NUMBER() OVER(ORDER BY a.testdate ASC) AS period,
			                    a.testdate
					    FROM (  SELECT DISTINCT ts.date AS testdate,
						                            dbo.F_ENDYEAR(ts.date, DEFAULT) AS schyr
									            FROM [fayette].[dbo].[TestScore] AS ts
										            WHERE ts.testID BETWEEN 1426 AND 1431) AS a
										    WHERE a.schyr = @schyr;


										    -- Returns the table variable
    RETURN;

  -- End of the function body
  END;

-- End of the function declaration
GO


