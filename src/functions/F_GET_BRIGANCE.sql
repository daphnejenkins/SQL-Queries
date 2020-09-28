 /***********************************************************************************************************************
*                                                                                                                      *
*  Name: F_GET_BRIGANCE                                                                                                *
*                                                                                                                      *
*  Description: Function used to return BRIGANCE Scores for Total Score, Physical Well-Being, Language/Communication,  *
*  Cognitive/General Knowledge, Adaptive Behavior, Self-Help Skills Performance, Social-Emotional Skills			   *
*	 for one or all students for a given school year.																   *
*                                                                                                                      *
***********************************************************************************************************************/

-- Checks if the function exists in the database
IF object_id(N'dbo.F_GET_BRIGANCE', N'TF') IS NOT NULL

  -- Drops the function if it already exists
  DROP FUNCTION dbo.F_GET_BRIGANCE;

-- End of batch block
GO

-- Defines the function F_GET_ACT
CREATE FUNCTION dbo.F_GET_BRIGANCE(@schyr SMALLINT, @persid INT = NULL)

  -- Defines the table that the function returns
  RETURNS @retval TABLE (pid INT PRIMARY KEY, schyr INT NOT NULL,
    brgtotraw SMALLINT, brgtotrst VARCHAR(100), brgtotpct SMALLINT, brgpwbraw SMALLINT, brgpwbrst VARCHAR(100), brpwbpct SMALLINT,
    brglcraw SMALLINT, brglcrst VARCHAR(100), brglcpct SMALLINT, brgcgkraw SMALLINT, brgcgkrst VARCHAR(100), brgcgkpct SMALLINT,
    brgabraw SMALLINT, brgabrst VARCHAR(100), brgabpct SMALLINT, brgshspraw SMALLINT, brgshsprst VARCHAR(100), brgshsppct SMALLINT,
    brgsesraw SMALLINT, brgsesrst VARCHAR(100), brgsespct SMALLINT) AS

  -- Starts the function body
  BEGIN

    -- If no personID is passed
    IF @persid IS NULL

      -- Use a common table expression to handle the correlated subqueries
      WITH a AS ( SELECT DISTINCT   a.pid, a.tid, MAX(a.[raw]) AS [raw], MAX(a.rst) AS rst, MAX(a.pct) AS pct
                  FROM (     SELECT DISTINCT  ts.personID AS pid,
                                              ts.testID AS tid,
                                              CAST(ts.rawScore AS SMALLINT) AS [raw],
                                              CAST(ts.result AS VARCHAR(100)) AS rst,
                                              CAST(ts.percentile AS SMALLINT) AS pct
                              FROM            [fayette].[dbo].[TestScore] AS ts
                              WHERE           ts.testID BETWEEN 1914 AND 1920 AND
                                              dbo.F_ENDYEAR(ts.date, DEFAULT) = @schyr AND
                                              (ts.rawScore IS NOT NULL OR ts.percentile IS NOT NULL OR ts.result IS NOT NULL)) AS a
                  GROUP BY          a.pid, a.tid)

      -- Put the data into the
      INSERT @retval(pid, schyr,
                    brgtotraw, brgtotrst, brgtotpct, brgpwbraw, brgpwbrst, brpwbpct,
    brglcraw, brglcrst, brglcpct, brgcgkraw, brgcgkrst, brgcgkpct,
    brgabraw, brgabrst, brgabpct, brgshspraw, brgshsprst, brgshsppct,
    brgsesraw, brgsesrst, brgsespct)
      SELECT DISTINCT   a.pid, @schyr AS schyr,
                        b.[raw] AS brgtotraw,
                        b.rst AS brgtotrst,
                        b.pct AS brgtotpct,
                        c.[raw] AS brpwbraw,
                        c.rst AS brgpwbrst,
                        c.pct AS brgpwbpct,
                        d.[raw] AS brglcraw,
                        d.rst AS brglcrst,
                        d.pct AS brglcpct,
                        e.[raw] AS brgcgkraw,
                        e.rst AS brgcgkrst,
                        e.pct AS brgcgkpct,
                        f.[raw] AS brgabraw,
                        f.rst AS brgabrst,
                        f.pct AS brgabpct,
                        g.[raw] AS brgshspraw,
                        g.rst AS brgshsprst,
                        g.pct AS brgshsppct,
                        h.[raw] AS brgsesraw,
                        h.rst AS brgsesrst,
                        h.pct AS brgsespct                        
                 
      FROM              a

      -- Total Score
      LEFT JOIN   		a AS b ON a.pid = b.pid AND b.tid = 1914 AND
                                  (b.[raw] IS NOT NULL OR b.pct IS NOT NULL OR b.rst IS NOT NULL)

      -- Physical Well-Being Score
      LEFT JOIN   		a AS c ON a.pid = c.pid AND c.tid = 1915 AND
                                  (c.[raw] IS NOT NULL OR c.pct IS NOT NULL OR c.rst IS NOT NULL)

      -- Language/Communication Score
      LEFT JOIN   		a AS d ON a.pid = d.pid AND d.tid = 1916 AND
                                  (d.[raw] IS NOT NULL OR d.pct IS NOT NULL OR d.rst IS NOT NULL)
                          
       -- Cognitive/General Knowledge Score
      LEFT JOIN   		a AS e ON a.pid = e.pid AND e.tid = 1917 AND
                                  (e.[raw] IS NOT NULL OR e.pct IS NOT NULL OR e.rst IS NOT NULL)
                                  
        -- Adaptive Behavior Score
      LEFT JOIN   		a AS f ON a.pid = f.pid AND f.tid = 1918 AND
                                  (f.[raw] IS NOT NULL OR f.pct IS NOT NULL OR f.rst IS NOT NULL)
        
        -- Self-Help Skills Performance Score
      LEFT JOIN   		a AS g ON a.pid = g.pid AND g.tid = 1919 AND
                                  (g.[raw] IS NOT NULL OR g.pct IS NOT NULL OR g.rst IS NOT NULL)
                                  
        -- Social-Emotional Skills Score
      LEFT JOIN   		a AS h ON a.pid = f.pid AND f.tid = 1918 AND
                                  (f.[raw] IS NOT NULL OR f.pct IS NOT NULL OR f.rst IS NOT NULL)


    -- If a person ID is passed to the function
    ELSE

      -- Use a common table expression to handle the correlated subqueries
      WITH a AS ( SELECT DISTINCT   a.pid, a.tid, MAX(a.[raw]) AS [raw], MAX(a.rst) AS rst, MAX(a.pct) AS pct
                  FROM (     SELECT DISTINCT  ts.personID AS pid,
                                              ts.testID AS tid,
                                              CAST(ts.rawScore AS SMALLINT) AS [raw],
                                              CAST(ts.result AS VARCHAR(100)) AS rst,
                                              CAST(ts.percentile AS SMALLINT) AS pct
                              FROM            [fayette].[dbo].[TestScore] AS ts
                              WHERE           ts.testID BETWEEN 1914 AND 1918 AND
                                              dbo.F_ENDYEAR(ts.date, DEFAULT) = @schyr AND
                                              ts.personID = @persid AND
                                              (ts.rawScore IS NOT NULL OR ts.percentile IS NOT NULL OR ts.result IS NOT NULL)) AS a
                  GROUP BY          a.pid, a.tid)
      -- Put the data into the
      INSERT @retval(pid, schyr,
                    brgtotraw, brgtotrst, brgtotpct, brgpwbraw, brgpwbrst, brpwbpct,
    brglcraw, brglcrst, brglcpct, brgcgkraw, brgcgkrst, brgcgkpct,
    brgabraw, brgabrst, brgabpct, brgshspraw, brgshsprst, brgshsppct,
    brgsesraw, brgsesrst, brgsespct)
      SELECT DISTINCT   a.pid, @schyr AS schyr,
                        b.[raw] AS brgtotraw,
                        b.rst AS brgtotrst,
                        b.pct AS brgtotpct,
                        c.[raw] AS brpwbraw,
                        c.rst AS brgpwbrst,
                        c.pct AS brgpwbpct,
                        d.[raw] AS brglcraw,
                        d.rst AS brglcrst,
                        d.pct AS brglcpct,
                        e.[raw] AS brgcgkraw,
                        e.rst AS brgcgkrst,
                        e.pct AS brgcgkpct,
                        f.[raw] AS brgabraw,
                        f.rst AS brgabrst,
                        f.pct AS brgabpct,
                        g.[raw] AS brgshspraw,
                        g.rst AS brgshsprst,
                        g.pct AS brgshsppct,
                        h.[raw] AS brgsesraw,
                        h.rst AS brgsesrst,
                        h.pct AS brgsespct
      FROM              a

       -- Total Score
      LEFT JOIN   		a AS b ON a.pid = b.pid AND b.tid = 1914 AND
                                  (b.[raw] IS NOT NULL OR b.pct IS NOT NULL OR b.rst IS NOT NULL)

      -- Physical Well-Being Score
      LEFT JOIN   		a AS c ON a.pid = c.pid AND c.tid = 1915 AND
                                  (c.[raw] IS NOT NULL OR c.pct IS NOT NULL OR c.rst IS NOT NULL)

      -- Language/Communication Score
      LEFT JOIN   		a AS d ON a.pid = d.pid AND d.tid = 1916 AND
                                  (d.[raw] IS NOT NULL OR d.pct IS NOT NULL OR d.rst IS NOT NULL)
                          
       -- Cognitive/General Knowledge Score
      LEFT JOIN   		a AS e ON a.pid = e.pid AND e.tid = 1917 AND
                                  (e.[raw] IS NOT NULL OR e.pct IS NOT NULL OR e.rst IS NOT NULL)
                                  
        -- Adaptive Behavior Score
      LEFT JOIN   		a AS f ON a.pid = f.pid AND f.tid = 1918 AND
                                  (f.[raw] IS NOT NULL OR f.pct IS NOT NULL OR f.rst IS NOT NULL)
        
        -- Self-Help Skills Performance Score
      LEFT JOIN   		a AS g ON a.pid = g.pid AND g.tid = 1919 AND
                                  (g.[raw] IS NOT NULL OR g.pct IS NOT NULL OR g.rst IS NOT NULL)
                                  
        -- Social-Emotional Skills Score
      LEFT JOIN   		a AS h ON a.pid = f.pid AND f.tid = 1918 AND
                                  (f.[raw] IS NOT NULL OR f.pct IS NOT NULL OR f.rst IS NOT NULL)
                                  
  -- Returns the table valued return object
  RETURN;

  -- End of the function body
  END

-- End of the batch statement
GO

-- Example of using the function to retrieve all records for the 2016-2017 school year
--SELECT *
--FROM FCPS_BB.dbo.F_GET_BRIGANCE(2015, DEFAULT);