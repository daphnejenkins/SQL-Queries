/***********************************************************************************************************************
*                                                                                                                      *
*  Name: F_GET_MAP                                                                                                     *
*                                                                                                                      *
*  Description: Function used to return NWEA MAP RIT Scores and Percentiles for Reading/Language Arts, Math, and       *
*  language for one or all students for a given school year.                                                           *
*                                                                                                                      *
***********************************************************************************************************************/

-- Checks if the function exists in the database
IF object_id(N'dbo.F_GET_MAP', N'TF') IS NOT NULL

  -- Drops the function if it already exists
  DROP FUNCTION dbo.F_GET_MAP;

-- End of batch block
GO

-- Defines the function F_GET_MAP
CREATE FUNCTION dbo.F_GET_MAP(@schyr SMALLINT, @persid INT = NULL)

  -- Defines the table that the function returns
  RETURNS @retval TABLE (pid INT PRIMARY KEY, schyr INT NOT NULL,
    mapmthsc1 SMALLINT, mapmthpct1 TINYINT, maprdgsc1 SMALLINT, maprdgpct1 TINYINT,
    maplansc1 SMALLINT, maplanpct1 TINYINT, mapmthsc2 SMALLINT, mapmthpct2 TINYINT,
    maprdgsc2 SMALLINT, maprdgpct2 TINYINT, maplansc2 SMALLINT, maplanpct2 TINYINT,
    mapmthsc3 SMALLINT, mapmthpct3 TINYINT, maprdgsc3 SMALLINT, maprdgpct3 TINYINT,
    maplansc3 SMALLINT, maplanpct3 TINYINT) AS

  -- Starts the function body
  BEGIN

    -- If no personID is passed
    IF @persid IS NULL

      -- Use a common table expression to handle the correlated subqueries
      WITH a AS ( SELECT DISTINCT   a.pid, a.tid, a.period, MAX(a.pct) AS pct, MAX(a.sc) AS sc
                  FROM (     SELECT DISTINCT  ts.personID AS pid,
                                              ts.testID AS tid,
                                              dbo.F_MAP_PERIODS(ts.date) AS period,
                                              CAST(ts.percentile AS TINYINT) AS pct,
                                              CAST(ts.scaleScore AS SMALLINT) AS sc
                              FROM            [fayette].[dbo].[TestScore] AS ts
                              WHERE           ts.testID BETWEEN 1427 AND 1429 AND
                                              dbo.F_ENDYEAR(ts.date, DEFAULT) = @schyr AND
                                              (ts.scaleScore IS NOT NULL OR ts.percentile IS NOT NULL)) AS a
                  GROUP BY          a.pid, a.tid, a.period)

      -- Put the data into the
      INSERT @retval(pid, schyr,
                    mapmthsc1, mapmthpct1, maprdgsc1, maprdgpct1, maplansc1, maplanpct1,
                    mapmthsc2, mapmthpct2, maprdgsc2, maprdgpct2, maplansc2, maplanpct2,
                    mapmthsc3, mapmthpct3, maprdgsc3, maprdgpct3, maplansc3, maplanpct3)
      SELECT DISTINCT   a2.pid, @schyr AS schyr,
                        b.sc AS mapmthsc1,
                        b.pct AS mapmthpct1,
                        c.sc AS maprdgsc1,
                        c.pct AS maprdgpct1,
                        d.sc AS maplansc1,
                        d.pct AS maplanpct1,
                        e.sc AS mapmthsc2,
                        e.pct AS mapmthpct2,
                        f.sc AS maprdgsc2,
                        f.pct AS maprdgpct2,
                        g.sc AS maplansc2,
                        g.pct AS maplanpct2,
                        h.sc AS mapmthsc3,
                        h.pct AS mapmthpct3,
                        i.sc AS maprdgsc3,
                        i.pct AS maprdgpct3,
                        j.sc AS maplansc3,
                        j.pct AS maplanpct3
      FROM              a

      -- Fall Math Scores
      LEFT JOIN   		a AS b ON a.pid = b.pid AND b.tid = 1427 AND b.period = 1 AND
                                  (b.sc IS NOT NULL OR b.pct IS NOT NULL)

      -- Fall Reading Scores
      LEFT JOIN   		a AS c ON a.pid = c.pid AND c.tid = 1428 AND c.period = 1 AND
                                  (c.sc IS NOT NULL OR c.pct IS NOT NULL)

      -- Fall Language Usage Scores
      LEFT JOIN   		a AS d ON a.pid = d.pid AND d.tid = 1429 AND d.period = 1 AND
                                  (d.sc IS NOT NULL OR d.pct IS NOT NULL)

      -- Winter Math Scores
      LEFT JOIN   		a AS e ON a.pid = e.pid AND e.tid = 1427 AND e.period = 2 AND
                                  (e.sc IS NOT NULL OR e.pct IS NOT NULL)

      -- Winter Reading Scores
      LEFT JOIN   		a AS f ON a.pid = f.pid AND f.tid = 1428 AND f.period = 2 AND
                                  (f.sc IS NOT NULL OR f.pct IS NOT NULL)

      -- Winter Language Usage Scores
      LEFT JOIN   		a AS g ON a.pid = g.pid AND g.tid = 1429 AND g.period = 2 AND
                                  (g.sc IS NOT NULL OR g.pct IS NOT NULL)

      -- Spring Math Scores
      LEFT JOIN   		a AS h ON a.pid = h.pid AND h.tid = 1427 AND h.period = 3 AND
                                  (h.sc IS NOT NULL OR h.pct IS NOT NULL)

      -- Spring Reading Scores
      LEFT JOIN   		a AS i ON a.pid = i.pid AND i.tid = 1428 AND i.period = 3 AND
                                  (i.sc IS NOT NULL OR i.pct IS NOT NULL)

      -- Spring Language Usage Scores
      LEFT JOIN   		a AS j ON a.pid = j.pid AND j.tid = 1429 AND j.period = 3 AND
                                  (j.sc IS NOT NULL OR j.pct IS NOT NULL);

    -- If a person ID is passed to the function
    ELSE

      -- Use a common table expression to handle the correlated subqueries
      WITH a AS ( SELECT DISTINCT   a.pid, a.tid, a.period, MAX(a.pct) AS pct, MAX(a.sc) AS sc
                  FROM (     SELECT DISTINCT  ts.personID AS pid,
                                              ts.testID AS tid,
                                              dbo.F_MAP_PERIODS(ts.date) AS period,
                                              CAST(ts.percentile AS TINYINT) AS pct,
                                              CAST(ts.scaleScore AS SMALLINT) AS sc
                              FROM            [fayette].[dbo].[TestScore] AS ts
                              WHERE           ts.testID BETWEEN 1427 AND 1429 AND
                                              dbo.F_ENDYEAR(ts.date, DEFAULT) = @schyr AND
                                              ts.personID = @persid AND
                                              (ts.scaleScore IS NOT NULL OR ts.percentile IS NOT NULL)) AS a
                  GROUP BY          a.pid, a.tid, a.period)
      -- Put the data into the
      INSERT @retval(pid, schyr,
                    mapmthsc1, mapmthpct1, maprdgsc1, maprdgpct1, maplansc1, maplanpct1,
                    mapmthsc2, mapmthpct2, maprdgsc2, maprdgpct2, maplansc2, maplanpct2,
                    mapmthsc3, mapmthpct3, maprdgsc3, maprdgpct3, maplansc3, maplanpct3)
      SELECT DISTINCT   a.pid, @schyr AS schyr,
                        b.sc AS mapmthsc1,
                        b.pct AS mapmthpct1,
                        c.sc AS maprdgsc1,
                        c.pct AS maprdgpct1,
                        d.sc AS maplansc1,
                        d.pct AS maplanpct1,
                        e.sc AS mapmthsc2,
                        e.pct AS mapmthpct2,
                        f.sc AS maprdgsc2,
                        f.pct AS maprdgpct2,
                        g.sc AS maplansc2,
                        g.pct AS maplanpct2,
                        h.sc AS mapmthsc3,
                        h.pct AS mapmthpct3,
                        i.sc AS maprdgsc3,
                        i.pct AS maprdgpct3,
                        j.sc AS maplansc3,
                        j.pct AS maplanpct3
      FROM              a

      -- Fall Math Scores
      LEFT JOIN   a AS b ON a.pid = b.pid AND b.tid = 1427 AND b.period = 1 AND
                                  (b.sc IS NOT NULL OR b.pct IS NOT NULL)

      -- Fall Reading Scores
      LEFT JOIN   a AS c ON a.pid = c.pid AND c.tid = 1428 AND c.period = 1 AND
                                  (c.sc IS NOT NULL OR c.pct IS NOT NULL)

      -- Fall Language Usage Scores
      LEFT JOIN   a AS d ON a.pid = d.pid AND d.tid = 1429 AND d.period = 1 AND
                                  (d.sc IS NOT NULL OR d.pct IS NOT NULL)

      -- Winter Math Scores
      LEFT JOIN   a AS e ON a.pid = e.pid AND e.tid = 1427 AND e.period = 2 AND
                                  (e.sc IS NOT NULL OR e.pct IS NOT NULL)

      -- Winter Reading Scores
      LEFT JOIN   a AS f ON a.pid = f.pid AND f.tid = 1428 AND f.period = 2 AND
                                  (f.sc IS NOT NULL OR f.pct IS NOT NULL)

      -- Winter Language Usage Scores
      LEFT JOIN   a AS g ON a.pid = g.pid AND g.tid = 1429 AND g.period = 2 AND
                                  (g.sc IS NOT NULL OR g.pct IS NOT NULL)

      -- Spring Math Scores
      LEFT JOIN   a AS h ON a.pid = h.pid AND h.tid = 1427 AND h.period = 3 AND
                                  (h.sc IS NOT NULL OR h.pct IS NOT NULL)

      -- Spring Reading Scores
      LEFT JOIN   a AS i ON a.pid = i.pid AND i.tid = 1428 AND i.period = 3 AND
                                  (i.sc IS NOT NULL OR i.pct IS NOT NULL)

      -- Spring Language Usage Scores
      LEFT JOIN   a AS j ON a.pid = j.pid AND j.tid = 1429 AND j.period = 3 AND
                                  (j.sc IS NOT NULL OR j.pct IS NOT NULL);

  -- Returns the table valued return object
  RETURN;

  -- End of the function body
  END

-- End of the batch statement
GO

-- Example of using the function to retrieve all records for the 2016-2017 school year
SELECT *
FROM FCPS_BB.dbo.F_GET_MAP(2015, DEFAULT);

