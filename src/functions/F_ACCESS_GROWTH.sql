IF OBJECT_ID('dbo.F_ACCESS_GROWTH', 'FN') IS NOT NULL
	DROP FUNCTION F_ACCESS_GROWTH;

GO

/*
	Defines a function used to look up the percentile growth bands given a vector of inputs.
	The inputs for the function
*/
CREATE FUNCTION dbo.F_ACCESS_GROWTH(@schyr SMALLINT, @grade TINYINT, @proflev DOUBLE PRECISION, @scalediff INT, @domain TINYINT)

-- Declares the return type of the function
RETURNS TINYINT AS

	-- Starts the beginning of the function body
	BEGIN

		-- Declares a variable to store the proficiency level band
		DECLARE @growthBand TINYINT

		-- If the difference in scaled scores is NULL
		IF @scalediff = NULL

			-- Return a NULL value
			SET @growthBand = NULL;

		-- For all other cases
		ELSE

			-- Queries the table given the input parameters for non-null score differences
			SET @growthBand = (
			SELECT		TOP 1 pctileband
			FROM 		[FCPS_BB].[dbo].ACCESS_PERCENTILE_BANDS
			WHERE 		@schyr BETWEEN pschyr AND cschyr AND
						@grade BETWEEN mingrade AND maxgrade AND
						@scalediff BETWEEN mindiff AND maxdiff AND
						ROUND(@proflev, 1) BETWEEN minplev AND maxplev AND
						domain = @domain);

		-- Return the value from the function
		RETURN(@growthBand);

	-- End of the function definition
	END

-- Process this batch
GO


