IF object_id(N'dbo.F_GET_KPREP', N'TF') IS NOT NULL
    DROP FUNCTION dbo.F_GET_KPREP;

GO

-- Defines function used to retrieve statewide accountability assessment data
CREATE FUNCTION dbo.F_GET_KPREP(@schyr SMALLINT, @persid INT)

  -- Defines the table structure returned by this function
	RETURNS @retval TABLE (
			pid INT PRIMARY KEY,
      schyr INT NOT NULL,
      kprmthsc INT,
      kprmthlev TINYINT,
      kprrlasc INT,
      kprrlalev TINYINT
		) AS

    -- Start of the function body
		BEGIN

      -- If no personID is passed
      IF @persid IS NULL

        -- Use a common table expression to handle the correlated subqueries
        WITH a AS ( SELECT DISTINCT   scores.pid, scores.tid, MAX(scores.lev) AS lev, MAX(scores.sc) AS sc
                    FROM (     SELECT DISTINCT  ts.personID AS pid,
                                                ts.testID AS tid,
                                                CAST(CASE
                                                        WHEN ts.result = 'N' THEN 1
                                                        WHEN ts.result = 'A' THEN 2
                                                        WHEN ts.result = 'P' THEN 3
                                                        WHEN ts.result = 'D' THEN 4
                                                        ELSE NULL
                                                    END AS TINYINT) AS lev,
                                                CAST(ts.scalescore AS SMALLINT) AS sc
                                FROM            [fayette].[dbo].[TestScore] AS ts
                                WHERE           ts.testID IN (1642, 1648, 1641, 1650) AND
                                                dbo.F_ENDYEAR(ts.date, DEFAULT) = @schyr AND
                                                (ts.scaleScore IS NOT NULL OR ts.result IS NOT NULL)) AS scores
                    GROUP BY          scores.pid, scores.tid)

        -- Put the data into the
        INSERT @retval(pid, schyr, kprmthsc, kprmthlev, kprrlasc, kprrlalev)
        SELECT DISTINCT   a.pid, @schyr AS schyr,
                          m.sc AS kprmthsc,
                          m.lev AS kprmthlev,
                          r.sc AS kprrlasc,
                          r.lev AS kprrlalev
        FROM              a

        -- Join used for math scores
        LEFT JOIN a AS m ON  m.pid = a.pid AND
                          m.tid IN (1642, 1648) AND
                          (m.sc IS NOT NULL OR m.lev IS NOT NULL)

        -- Join used for reading scores
        LEFT JOIN a AS r ON  r.pid = a.pid AND
                          r.tid IN (1641, 1650) AND
                          (r.sc IS NOT NULL OR r.lev IS NOT NULL)

        -- Eliminates records without any test score data
        WHERE m.lev IS NOT NULL OR m.sc IS NOT NULL OR r.lev IS NOT NULL OR r.sc IS NOT NULL;

      -- If a person ID is passed to the function
      ELSE

        -- Use a common table expression to handle the correlated subqueries
        WITH a AS ( SELECT DISTINCT   scores.pid, scores.tid, MAX(scores.lev) AS lev, MAX(scores.sc) AS sc
                    FROM (     SELECT DISTINCT  ts.personID AS pid,
                                                ts.testID AS tid,
                                                CAST(CASE
                                                        WHEN ts.result = 'N' THEN 1
                                                        WHEN ts.result = 'A' THEN 2
                                                        WHEN ts.result = 'P' THEN 3
                                                        WHEN ts.result = 'D' THEN 4
                                                        ELSE NULL
                                                    END AS TINYINT) AS lev,
                                                CAST(ts.scalescore AS SMALLINT) AS sc
                                FROM            [fayette].[dbo].[TestScore] AS ts
                                WHERE           ts.testID IN (1642, 1648, 1641, 1650) AND
                                                dbo.F_ENDYEAR(ts.date, DEFAULT) = @schyr AND
                                                (ts.scaleScore IS NOT NULL OR ts.result IS NOT NULL) AND
                                                ts.personID = @persid) AS scores
                    GROUP BY          scores.pid, scores.tid)

        -- Put the data into the
        INSERT @retval(pid, schyr, kprmthsc, kprmthlev, kprrlasc, kprrlalev)
        SELECT DISTINCT   a.pid, @schyr AS schyr,
                          m.sc AS kprmthsc,
                          m.lev AS kprmthlev,
                          r.sc AS kprrlasc,
                          r.lev AS kprrlalev
        FROM              a

        -- Join used for math scores
        LEFT JOIN a AS m ON  m.pid = a.pid AND
                          m.tid IN (1642, 1648) AND
                          (m.sc IS NOT NULL OR m.lev IS NOT NULL)

        -- Join used for reading scores
        LEFT JOIN a AS r ON  r.pid = a.pid AND
                          r.tid IN (1641, 1650) AND
                          (r.sc IS NOT NULL OR r.lev IS NOT NULL)

        -- Eliminates records without any test score data
        WHERE m.lev IS NOT NULL OR m.sc IS NOT NULL OR r.lev IS NOT NULL OR r.sc IS NOT NULL;

    -- Returns the table valued return object
    RETURN;

  -- End of the function body
  END

GO

-- Returns 23,390 records ~ 8-10 seconds execution time
SELECT *
FROM dbo.F_GET_KPREP(2016, DEFAULT);

-- Returns a single record for the student with person ID 2 in ~ 246ms total
SELECT *
FROM dbo.F_GET_KPREP(2016, 2);