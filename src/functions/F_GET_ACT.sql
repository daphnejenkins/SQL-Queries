/***********************************************************************************************************************
*                                                                                                                      *
*  Name: F_GET_ACT                                                                                                   *
*                                                                                                                      *
*  Description: Function used to return ACT Scores for Mathematics, Critical Reading, and Writing *
*	 for one or all students for a given school year.																   *
*                                                                                                                      *
***********************************************************************************************************************/

-- Checks if the function exists in the database
IF object_id(N'dbo.F_GET_ACT', N'TF') IS NOT NULL

  -- Drops the function if it already exists
  DROP FUNCTION dbo.F_GET_ACT;

-- End of batch block
GO

-- Defines the function F_GET_ACT
CREATE FUNCTION dbo.F_GET_ACT(@schyr SMALLINT, @persid INT = NULL)

  -- Defines the table that the function returns
  RETURNS @retval TABLE (pid INT PRIMARY KEY, schyr INT NOT NULL,
    actcmpsc SMALLINT, actengsc SMALLINT, actmthsc SMALLINT, actrdsc SMALLINT, actscisc SMALLINT) AS

  -- Starts the function body
  BEGIN

    -- If no personID is passed
    IF @persid IS NULL

      -- Use a common table expression to handle the correlated subqueries
      WITH a AS ( SELECT DISTINCT   a.pid, a.tid, MAX(a.sc) AS sc
                  FROM (     SELECT DISTINCT  ts.personID AS pid,
                                              ts.testID AS tid,
                                              CAST(ts.scaleScore AS SMALLINT) AS sc
                              FROM            [fayette].[dbo].[TestScore] AS ts
                              WHERE           ts.testID BETWEEN 290 AND 301 AND
                                              dbo.F_ENDYEAR(ts.date, DEFAULT) = @schyr AND
                                              (ts.scaleScore IS NOT NULL)) AS a
                  GROUP BY          a.pid, a.tid)

      -- Put the data into the
      INSERT @retval(pid, schyr,
                    actcmpsc, actengsc, actmthsc, actrdsc, actscisc)
      SELECT DISTINCT   a.pid, @schyr AS schyr,
                        b.sc AS actcmpsc,
                        c.sc AS actengsc,
                        d.sc AS actmthsc,
                        e.sc AS actrdsc,
                        f.sc AS actscisc                        
                 
      FROM              a

      -- Composite Scores
      LEFT JOIN   		a AS b ON a.pid = b.pid AND b.tid = 290 AND
                                  (b.sc IS NOT NULL)

      -- English Scores
      LEFT JOIN   		a AS c ON a.pid = c.pid AND c.tid = 291 AND
                                  (c.sc IS NOT NULL)

      -- Mathematics Scores
      LEFT JOIN   		a AS d ON a.pid = d.pid AND d.tid = 294 AND
                                  (d.sc IS NOT NULL)
                          
       -- Reading Scores
      LEFT JOIN   		a AS e ON a.pid = e.pid AND e.tid = 298 AND
                                  (d.sc IS NOT NULL)
                                  
        -- Science Scores
      LEFT JOIN   		a AS f ON a.pid = f.pid AND f.tid = 301 AND
                                  (d.sc IS NOT NULL)


    -- If a person ID is passed to the function
    ELSE

      -- Use a common table expression to handle the correlated subqueries
      WITH a AS ( SELECT DISTINCT   a.pid, a.tid, MAX(a.sc) AS sc
                  FROM (     SELECT DISTINCT  ts.personID AS pid,
                                              ts.testID AS tid,
                                              CAST(ts.scaleScore AS SMALLINT) AS sc
                              FROM            [fayette].[dbo].[TestScore] AS ts
                              WHERE           ts.testID BETWEEN 290 AND 301 AND
                                              dbo.F_ENDYEAR(ts.date, DEFAULT) = @schyr AND
                                              ts.personID = @persid AND
                                              (ts.scaleScore IS NOT NULL)) AS a
                  GROUP BY          a.pid, a.tid)
      -- Put the data into the
      INSERT @retval(pid, schyr,
                    actcmpsc, actengsc, actmthsc, actrdsc, actscisc)
      SELECT DISTINCT   a.pid, @schyr AS schyr,
                        b.sc AS actcmpsc,
                        c.sc AS actengsc,
                        d.sc AS actmthsc,
                        e.sc AS actrdsc,
                        f.sc AS actscisc
      FROM              a

       -- Composite Scores
      LEFT JOIN   		a AS b ON a.pid = b.pid AND b.tid = 290 AND
                                  (b.sc IS NOT NULL)

      -- English Scores
      LEFT JOIN   		a AS c ON a.pid = c.pid AND c.tid = 291 AND
                                  (c.sc IS NOT NULL)

      -- Mathematics Scores
      LEFT JOIN   		a AS d ON a.pid = d.pid AND d.tid = 294 AND
                                  (d.sc IS NOT NULL)
                          
       -- Reading Scores
      LEFT JOIN   		a AS e ON a.pid = e.pid AND e.tid = 298 AND
                                  (d.sc IS NOT NULL)
                                  
        -- Science Scores
      LEFT JOIN   		a AS f ON a.pid = f.pid AND f.tid = 301 AND
                                  (d.sc IS NOT NULL)
                                  
  -- Returns the table valued return object
  RETURN;

  -- End of the function body
  END

-- End of the batch statement
GO

-- Example of using the function to retrieve all records for the 2016-2017 school year
--SELECT *
--FROM FCPS_BB.dbo.F_GET_ACT(2016, DEFAULT);