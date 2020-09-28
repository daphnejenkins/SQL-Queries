/***********************************************************************************************************************
*                                                                                                                      *
*  Name: F_GET_PSAT                                                                                                    *
*                                                                                                                      *
*  Description: Function used to return PSAT RIT Scores and Percentiles for Mathematics, Critical Reading, and Writing *
*	 for one or all students for a given school year.																   *
*                                                                                                                      *
***********************************************************************************************************************/

-- Checks if the function exists in the database
IF object_id(N'dbo.F_GET_PSAT', N'TF') IS NOT NULL

  -- Drops the function if it already exists
  DROP FUNCTION dbo.F_GET_PSAT;

-- End of batch block
GO

-- Defines the function F_GET_PSAT
CREATE FUNCTION dbo.F_GET_PSAT(@schyr SMALLINT, @persid INT = NULL)

  -- Defines the table that the function returns
  RETURNS @retval TABLE (pid INT PRIMARY KEY, schyr INT NOT NULL,
    psamthsc SMALLINT, psamthpct TINYINT, psardsc SMALLINT, psardpct TINYINT, psawrtsc SMALLINT, psawrtpct TINYINT) AS

  -- Starts the function body
  BEGIN

    -- If no personID is passed
    IF @persid IS NULL

      -- Use a common table expression to handle the correlated subqueries
      WITH a AS ( SELECT DISTINCT   a.pid, a.tid, MAX(a.pct) AS pct, MAX(a.sc) AS sc
                  FROM (     SELECT DISTINCT  ts.personID AS pid,
                                              ts.testID AS tid,
                                              CAST(ts.percentile AS TINYINT) AS pct,
                                              CAST(ts.scaleScore AS SMALLINT) AS sc
                              FROM            [fayette].[dbo].[TestScore] AS ts
                              WHERE           ts.testID BETWEEN 317 AND 319 AND
                                              dbo.F_ENDYEAR(ts.date, DEFAULT) = @schyr AND
                                              (ts.scaleScore IS NOT NULL OR ts.percentile IS NOT NULL)) AS a
                  GROUP BY          a.pid, a.tid)

      -- Put the data into the
      INSERT @retval(pid, schyr,
                    pastmthsc, psatmthpct, psatrdsc, psatrdpct, psatwrtsc, psatwrtpct)
      SELECT DISTINCT   a.pid, @schyr AS schyr,
                        b.sc AS psamthsc,
                        b.pct AS psamthpct,
                        c.sc AS psardsc,
                        c.pct AS psardpct,
                        d.sc AS psawrtsc,
                        d.pct AS psawrtpct
                 
      FROM              a

      -- Math Scores
      LEFT JOIN   		a AS b ON a.pid = b.pid AND b.tid = 317 AND
                                  (b.sc IS NOT NULL OR b.pct IS NOT NULL)

      -- Critical Reading Scores
      LEFT JOIN   		a AS c ON a.pid = c.pid AND c.tid = 318 AND
                                  (c.sc IS NOT NULL OR c.pct IS NOT NULL)

      -- Writing Scores
      LEFT JOIN   		a AS d ON a.pid = d.pid AND d.tid = 319 AND
                                  (d.sc IS NOT NULL OR d.pct IS NOT NULL)


    -- If a person ID is passed to the function
    ELSE

      -- Use a common table expression to handle the correlated subqueries
      WITH a AS ( SELECT DISTINCT   a.pid, a.tid, MAX(a.pct) AS pct, MAX(a.sc) AS sc
                  FROM (     SELECT DISTINCT  ts.personID AS pid,
                                              ts.testID AS tid,
                                              CAST(ts.percentile AS TINYINT) AS pct,
                                              CAST(ts.scaleScore AS SMALLINT) AS sc
                              FROM            [fayette].[dbo].[TestScore] AS ts
                              WHERE           ts.testID BETWEEN 317 AND 319 AND
                                              dbo.F_ENDYEAR(ts.date, DEFAULT) = @schyr AND
                                              ts.personID = @persid AND
                                              (ts.scaleScore IS NOT NULL OR ts.percentile IS NOT NULL)) AS a
                  GROUP BY          a.pid, a.tid)
      -- Put the data into the
      INSERT @retval(pid, schyr,
                    pastmthsc, psatmthpct, psatrdsc, psatrdpct, psatwrtsc, psatwrtpct)
      SELECT DISTINCT   a.pid, @schyr AS schyr,
                        b.sc AS psamthsc,
                        b.pct AS psamthpct,
                        c.sc AS psardsc,
                        c.pct AS psardpct,
                        d.sc AS psawrtsc,
                        d.pct AS psawrtpct
      FROM              a

       -- Math Scores
      LEFT JOIN   		a AS b ON a.pid = b.pid AND b.tid = 317 AND
                                  (b.sc IS NOT NULL OR b.pct IS NOT NULL)

      -- Critical Reading Scores
      LEFT JOIN   		a AS c ON a.pid = c.pid AND c.tid = 318 AND
                                  (c.sc IS NOT NULL OR c.pct IS NOT NULL)

      -- Writing Scores
      LEFT JOIN   		a AS d ON a.pid = d.pid AND d.tid = 319 AND
                                  (d.sc IS NOT NULL OR d.pct IS NOT NULL)

  -- Returns the table valued return object
  RETURN;

  -- End of the function body
  END

-- End of the batch statement
GO

-- Example of using the function to retrieve all records for the 2016-2017 school year
SELECT *
FROM FCPS_BB.dbo.F_GET_PSAT(2015, DEFAULT);