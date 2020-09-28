-- Drops table if it already exists and then rebuilds it
IF OBJECT_ID('dbo.MAP_CCR', 'U') IS NOT NULL
	DROP TABLE dbo.MAP_CCR;


	-- Drops table if it already exists and then rebuilds it
IF OBJECT_ID('dbo.MAP_SUBJECTS', 'U') IS NOT NULL
	DROP TABLE dbo.MAP_SUBJECTS;

-- Tests to see if function is already defined
IF OBJECT_ID('dbo.F_ONTRACK_MAP', 'FN') IS NOT NULL
	DROP FUNCTION dbo.F_ONTRACK_MAP;

	-- Builds a table of MAP subject areas
CREATE TABLE dbo.MAP_SUBJECTS (
	id INT NOT NULL PRIMARY KEY,
	content_area VARCHAR(23) NOT NULL
);

-- Inserts the data into the table to provide a mapping from numeric codes to subject area strings
INSERT dbo.MAP_SUBJECTS
VALUES (1431, 'Concepts and Processes'), (1430, 'General Science'),
   (1429, 'Language Usage'), (1427, 'Mathematics'), (1428, 'Reading');


-- Builds a table that stores the look up values used for the college/career on-path indicator for the score card
/*
 subject = 1427 is Math
 subject = 1428 is Reading
 term = 1 is Fall
 term = 3 is Spring
*/
CREATE TABLE dbo.MAP_CCR (
  grade TINYINT NOT NULL,
  term TINYINT NOT NULL,
  actsc TINYINT NOT NULL,
  subject SMALLINT NOT NULL,
  benchmark DECIMAL NOT NULL,
  stderror DECIMAL NOT NULL,
  pctile SMALLINT NOT NULL,
  truepos DECIMAL NOT NULL,
  falsepos DECIMAL NOT NULL,
  CONSTRAINT pk_map_readiness PRIMARY KEY (grade, term, actsc, subject)
);

-- Inserts the subject area codes, grade levels, and threshold values for the on-path indicators
INSERT dbo.MAP_CCR (grade, term, actsc, subject, benchmark, stderror, pctile, truepos, falsepos)
VALUES (5, 1, 22, 1427, 217.31, 0.04, 65, 0.67, 0.19),
(5, 1, 24, 1427, 221.33, 0.04, 74, 0.63, 0.15),
(5, 3, 22, 1427, 225.58, 0.04, 61, 0.70, 0.16),
(5, 3, 24, 1427, 229.74, 0.04, 70, 0.67, 0.14),
(6, 1, 22, 1427, 225.30, 0.04, 68, 0.70, 0.15),
(6, 1, 24, 1427, 229.63, 0.04, 79, 0.68, 0.13),
(6, 3, 22, 1427, 232.34, 0.03, 66, 0.72, 0.14),
(6, 3, 24, 1427, 236.82, 0.03, 76, 0.68, 0.11),
(7, 1, 22, 1427, 232.20, 0.03, 71, 0.72, 0.13),
(7, 1, 24, 1427, 236.84, 0.03, 81, 0.68, 0.10),
(7, 3, 22, 1427, 238.06, 0.03, 70, 0.73, 0.13),
(7, 3, 24, 1427, 242.85, 0.03, 79, 0.70, 0.10),
(8, 1, 22, 1427, 238.00, 0.03, 74, 0.73, 0.13),
(8, 1, 24, 1427, 242.96, 0.03, 83, 0.70, 0.10),
(8, 3, 22, 1427, 242.73, 0.04, 74, 0.73, 0.13),
(8, 3, 24, 1427, 247.83, 0.04, 81, 0.70, 0.10),
(9, 1, 22, 1427, 242.72, 0.04, 76, 0.73, 0.13),
(9, 1, 24, 1427, 247.99, 0.04, 84, 0.69, 0.10),
(9, 3, 22, 1427, 246.35, 0.04, 74, 0.73, 0.13),
(9, 3, 24, 1427, 251.76, 0.04, 83, 0.70, 0.10),
(5, 1, 22, 1428, 209.31, 0.04, 59, 0.71, 0.20),
(5, 1, 24, 1428, 212.62, 0.04, 69, 0.70, 0.18),
(5, 3, 22, 1428, 214.70, 0.04, 59, 0.72, 0.18),
(5, 3, 24, 1428, 217.94, 0.04, 66, 0.72, 0.17),
(6, 1, 22, 1428, 214.97, 0.04, 61, 0.73, 0.18),
(6, 1, 24, 1428, 218.32, 0.04, 68, 0.72, 0.16),
(6, 3, 22, 1428, 219.59, 0.03, 61, 0.74, 0.17),
(6, 3, 24, 1428, 222.87, 0.03, 69, 0.73, 0.15),
(7, 1, 22, 1428, 219.83, 0.03, 64, 0.74, 0.17),
(7, 1, 24, 1428, 223.21, 0.03, 71, 0.73, 0.15),
(7, 3, 22, 1428, 223.73, 0.03, 65, 0.75, 0.16),
(7, 3, 24, 1428, 227.04, 0.03, 72, 0.73, 0.13),
(8, 1, 22, 1428, 223.88, 0.03, 67, 0.75, 0.16),
(8, 1, 24, 1428, 227.31, 0.03, 73, 0.73, 0.14),
(8, 3, 22, 1428, 227.10, 0.03, 67, 0.75, 0.16),
(8, 3, 24, 1428, 230.46, 0.03, 74, 0.73, 0.14),
(9, 1, 22, 1428, 227.14, 0.04, 67, 0.74, 0.17),
(9, 1, 24, 1428, 230.61, 0.04, 75, 0.73, 0.16),
(9, 3, 22, 1428, 229.72, 0.04, 69, 0.74, 0.17),
(9, 3, 24, 1428, 233.11, 0.04, 75, 0.72, 0.15);

-- Generates on-path to college/career readiness indicator
CREATE FUNCTION dbo.F_ONTRACK_MAP(@grade TINYINT, @term TINYINT, @subject SMALLINT, @benchmark TINYINT, @score DECIMAL)

  -- Returns a value of 0.0, 1.0, or NULL 
  -- Where 0.0 is not on track
  -- Where 1.0 is on track
  -- Where NULL is an invalid set of parameter values or undefined
  RETURNS DECIMAL

  AS

  -- Starts the function body
  BEGIN

    -- Declares the variables used to store the threshold and return value
    DECLARE @ret DECIMAL, @threshold DECIMAL;

    -- If any invalid parameters passed to the function
    IF (@grade NOT IN (5, 6, 7, 8, 9) OR 
    	@term NOT IN (1, 3) OR
 		@benchmark NOT IN (22, 24) OR 
 		@subject NOT IN (1427, 1428)) 
 			
 			-- Returns a NULL value
 			SET @ret = NULL;

 	-- If all parameter values are valid
    ELSE

    	-- Start code block for valid case handling
		BEGIN

			-- Looks up the threshold for the specified parameter values
			SET @threshold = (	SELECT 	benchmark
					  			FROM 	dbo.MAP_CCR
					  			WHERE 	grade = @grade AND 
					  					term = @term AND
					  					actsc = @benchmark AND 
					  					subject = @subject );

			-- Test whether current score is equal to or greater than threshold value
			-- If it is set the indicator value to 1.0
			IF (@score >= @threshold) SET @ret = 1.0;

			-- Otherwise set the value to 0.0 (not on track)
			ELSE SET @ret = 0.0;

		-- Ends the code block for the ELSE clause	
		END

	-- Returns the return value from the function
    RETURN(@ret);

  -- Ends the function body/definition
  END

-- Ends this batch
GO

/* The lines below define two simple test cases that can be used to do a simple/quick comparison */
-- Should return value of 0.0
SELECT dbo.F_ONTRACK_MAP(5, 3, 1427, 22, 225.0) AS ontrack;

-- Should return value of 1.0
SELECT dbo.F_ONTRACK_MAP(5, 3, 1427, 22, 226.0) AS ontrack;

