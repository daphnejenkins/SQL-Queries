-- Checks for the existence of the function
IF object_id(N'dbo.F_GET_ACCESS', N'TF') IS NOT NULL

    -- Drops the function if it does exist
    DROP FUNCTION dbo.F_GET_ACCESS;

-- End of the batch block
GO

-- Defines function used to retrieve ACCESS for ELL assessment data
CREATE FUNCTION dbo.F_GET_ACCESS(@schyr SMALLINT, @persid INT)

  -- Defines the table structure returned by this function
	RETURNS @retval TABLE (
			pid INT PRIMARY KEY,
      schyr INT NOT NULL,
      alt BIT,
      tier VARCHAR(1),
      cluster INT,
      acclstlev DOUBLE PRECISION,
      acclstsc INT,
      accrdglev DOUBLE PRECISION,
      accrdgsc INT,
      accspklev DOUBLE PRECISION,
      accspksc INT,
      accwrtlev DOUBLE PRECISION,
      accwrtsc INT,
      acctotlev DOUBLE PRECISION,
      acctotsc INT,
      acccmplev DOUBLE PRECISION,
      acccmpsc INT,
      accoralev DOUBLE PRECISION,
      accorasc INT,
      acclrclev DOUBLE PRECISION,
      acclrcsc INT
	) AS

    -- Start of the function body
		BEGIN

      -- If no personID is passed
      IF @persid IS NULL

        -- Use a common table expression to handle the correlated subqueries
        WITH a AS ( SELECT DISTINCT   scores.pid, scores.tid, scores.tier, MAX(scores.lev) AS lev, MAX(scores.sc) AS sc
                    FROM (     SELECT DISTINCT  ts.personID AS pid,
                                                ts.testID AS tid,
                                                CAST(
                                                    (CASE
                                                        WHEN ts.result = 'A1' THEN 1.0
                                                        WHEN ts.result = 'A2' THEN 2.0
                                                        WHEN ts.result = 'A3' THEN 3.0
                                                        WHEN ts.result = 'P1' THEN 4.0
                                                        WHEN ts.result = 'P2' THEN 5.0
                                                        WHEN ts.result = 'P3' THEN 6.0
                                                        ELSE ts.result
                                                    END)
                                                    AS DOUBLE PRECISION) AS lev,
                                                CAST(ts.scalescore AS INT) AS sc,
                                                ts.custom1 AS tier
                                FROM            [fayette].[dbo].[TestScore] AS ts
                                WHERE           ts.testID IN (1484, 1485, 1339, 1493, 1341, 1343,
                                							  1490, 1495, 1340, 1342) AND
                                                dbo.F_ENDYEAR(ts.date, DEFAULT) = @schyr AND
                                                (ts.scaleScore IS NOT NULL OR ts.result IS NOT NULL)) AS scores
                    GROUP BY          scores.pid, scores.tid, scores.tier)

        -- Put the data into the
        INSERT @retval(pid, schyr, alt, tier, cluster, acclstlev, acclstsc, accrdglev, accrdgsc, accspklev, accspksc,
        			   accwrtlev, accwrtsc, acctotlev, acctotsc, acccmplev, acccmpsc, accoralev, accorasc,
        			   acclrclev, acclrcsc)
        SELECT DISTINCT   a.pid, @schyr AS schyr,
                          CASE
                            WHEN t.tier = 'T' THEN 1
                            ELSE 0
                          END AS alt,
                          t.tier, cl.sc AS cluster,
        				  lst.lev AS acclstlev, lst.sc AS acclstsc, rdg.lev AS accrdglev, rdg.sc AS accrdgsc,
        				  spk.lev AS accspklev, spk.sc AS accspksc, wrt.lev AS accwrtlev, wrt.sc AS accwrtsc,
        				  tot.lev AS acctotlev, tot.sc AS acctotsc, cmp.lev AS acccmplev, cmp.sc AS acccmpsc,
        				  ora.lev AS accoralev, ora.sc AS accorasc, lrc.lev AS acclrclev, lrc.sc AS acclrcsc

        FROM              a

        -- Join used for ACCESS Tier Levels
        LEFT JOIN (SELECT ts2.personID AS pid, ts2.custom1 AS tier
                   FROM   [fayette].[dbo].[TestScore] AS ts2
                   WHERE  ts2.testID = 1485 AND dbo.F_ENDYEAR(ts2.date, DEFAULT) = @schyr) AS t ON t.pid = a.pid

        -- Join used for ACCESS cluster
        LEFT JOIN a AS cl ON  cl.pid = a.pid AND cl.tid = 1484

        -- Join used for ACCESS listening scores
        LEFT JOIN a AS lst ON lst.pid = a.pid AND lst.tid = 1339 AND (lst.sc IS NOT NULL OR lst.lev IS NOT NULL)

        -- Gets reading scores from ACCESS assessment
        LEFT JOIN a AS rdg ON rdg.pid = a.pid AND rdg.tid = 1340 AND (rdg.sc IS NOT NULL OR rdg.lev IS NOT NULL)

        -- Gets speaking scores from ACCESS assessment
        LEFT JOIN a AS spk ON spk.pid = a.pid AND spk.tid = 1341 AND (spk.sc IS NOT NULL OR spk.lev IS NOT NULL)

        -- Gets writing scores from ACCESS assessment
        LEFT JOIN a AS wrt ON wrt.pid = a.pid AND wrt.tid = 1342 AND (wrt.sc IS NOT NULL OR wrt.lev IS NOT NULL)

        -- Gets composite/overall scores from ACCESS assessment
        LEFT JOIN a AS tot ON tot.pid = a.pid AND tot.tid = 1343 AND (tot.sc IS NOT NULL OR tot.lev IS NOT NULL)

        -- Gets comprehension scores from ACCESS assessment
        LEFT JOIN a AS cmp ON cmp.pid = a.pid AND cmp.tid = 1490 AND (cmp.sc IS NOT NULL OR cmp.lev IS NOT NULL)

        -- Gets oral language scores from ACCESS assessment
        LEFT JOIN a AS ora ON ora.pid = a.pid AND ora.tid = 1493 AND (ora.sc IS NOT NULL OR ora.lev IS NOT NULL)

        -- Gets literacy scores from ACCESS assessment
        LEFT JOIN a AS lrc ON lrc.pid = a.pid AND lrc.tid = 1495 AND (lrc.sc IS NOT NULL OR lrc.lev IS NOT NULL)

        -- Eliminates records without any test score data
        WHERE 	lst.lev IS NOT NULL OR lst.sc IS NOT NULL OR rdg.lev IS NOT NULL OR rdg.sc IS NOT NULL OR
    			      spk.lev IS NOT NULL OR spk.sc IS NOT NULL OR wrt.lev IS NOT NULL OR wrt.sc IS NOT NULL OR
                tot.lev IS NOT NULL OR tot.sc IS NOT NULL OR cmp.lev IS NOT NULL OR cmp.sc IS NOT NULL OR
                ora.lev IS NOT NULL OR ora.sc IS NOT NULL OR lrc.lev IS NOT NULL OR lrc.sc IS NOT NULL;

      -- If a person ID is passed to the function
      ELSE

        WITH a AS ( SELECT DISTINCT   scores.pid, scores.tid, scores.tier, MAX(scores.lev) AS lev, MAX(scores.sc) AS sc
                    FROM (     SELECT DISTINCT  ts.personID AS pid,
                                                ts.testID AS tid,
                                                CAST((CASE
                                                        WHEN ts.result = 'A1' THEN 1.0
                                                        WHEN ts.result = 'A2' THEN 2.0
                                                        WHEN ts.result = 'A3' THEN 3.0
                                                        WHEN ts.result = 'P1' THEN 4.0
                                                        WHEN ts.result = 'P2' THEN 5.0
                                                        WHEN ts.result = 'P3' THEN 6.0
                                                        ELSE ts.result
                                                    END) AS DOUBLE PRECISION) AS lev,
                                                CAST(ts.scalescore AS INT) AS sc,
                                                CAST(ts.custom1 AS VARCHAR(1)) AS tier
                                FROM            [fayette].[dbo].[TestScore] AS ts
                                WHERE           ts.testID IN (1484, 1485, 1339, 1493, 1341, 1343,
                                							  1490, 1495, 1340, 1342) AND
                                                dbo.F_ENDYEAR(ts.date, DEFAULT) = @schyr AND
                                                (ts.scaleScore IS NOT NULL OR ts.result IS NOT NULL) AND
                                                ts.personID = @persid) AS scores
                    GROUP BY          scores.pid, scores.tid, scores.tier)

        -- Put the data into the
        INSERT @retval(pid, schyr, alt, tier, cluster, acclstlev, acclstsc, accrdglev, accrdgsc, accspklev, accspksc,
        			   accwrtlev, accwrtsc, acctotlev, acctotsc, acccmplev, acccmpsc, accoralev, accorasc,
        			   acclrclev, acclrcsc)
        SELECT DISTINCT   a.pid, @schyr AS schyr,
                          CASE
                            WHEN t.tier = 'T' THEN 1
                            ELSE 0
                          END AS alt, t.tier, cl.sc AS cluster,
        				  lst.lev AS acclstlev, lst.sc AS acclstsc, rdg.lev AS accrdglev, rdg.sc AS accrdgsc,
        				  spk.lev AS accspklev, spk.sc AS accspksc, wrt.lev AS accwrtlev, wrt.sc AS accwrtsc,
        				  tot.lev AS acctotlev, tot.sc AS acctotsc, cmp.lev AS acccmplev, cmp.sc AS acccmpsc,
        				  ora.lev AS accoralev, ora.sc AS accorasc, lrc.lev AS acclrclev, lrc.sc AS acclrcsc

        FROM              a

        -- Join used for ACCESS Tier Levels
        LEFT JOIN (SELECT ts2.personID AS pid, ts2.custom1 AS tier
                   FROM   [fayette].[dbo].[TestScore] AS ts2
                   WHERE  ts2.testID = 1485 AND dbo.F_ENDYEAR(ts2.date, DEFAULT) = @schyr) AS t ON t.pid = a.pid

        -- Join used for ACCESS cluster
        LEFT JOIN a AS cl ON  cl.pid = a.pid AND cl.tid = 1484

        -- Join used for ACCESS listening scores
        LEFT JOIN a AS lst ON lst.pid = a.pid AND lst.tid = 1339 AND (lst.sc IS NOT NULL OR lst.lev IS NOT NULL)

        -- Gets reading scores from ACCESS assessment
        LEFT JOIN a AS rdg ON rdg.pid = a.pid AND rdg.tid = 1340 AND (rdg.sc IS NOT NULL OR rdg.lev IS NOT NULL)

        -- Gets speaking scores from ACCESS assessment
        LEFT JOIN a AS spk ON spk.pid = a.pid AND spk.tid = 1341 AND (spk.sc IS NOT NULL OR spk.lev IS NOT NULL)

        -- Gets writing scores from ACCESS assessment
        LEFT JOIN a AS wrt ON wrt.pid = a.pid AND wrt.tid = 1342 AND (wrt.sc IS NOT NULL OR wrt.lev IS NOT NULL)

        -- Gets composite/overall scores from ACCESS assessment
        LEFT JOIN a AS tot ON tot.pid = a.pid AND tot.tid = 1343 AND (tot.sc IS NOT NULL OR tot.lev IS NOT NULL)

        -- Gets comprehension scores from ACCESS assessment
        LEFT JOIN a AS cmp ON cmp.pid = a.pid AND cmp.tid = 1490 AND (cmp.sc IS NOT NULL OR cmp.lev IS NOT NULL)

        -- Gets oral language scores from ACCESS assessment
        LEFT JOIN a AS ora ON ora.pid = a.pid AND ora.tid = 1493 AND (ora.sc IS NOT NULL OR ora.lev IS NOT NULL)

        -- Gets literacy scores from ACCESS assessment
        LEFT JOIN a AS lrc ON lrc.pid = a.pid AND lrc.tid = 1495 AND (lrc.sc IS NOT NULL OR lrc.lev IS NOT NULL)

        -- Eliminates records without any test score data
        WHERE 	lst.lev IS NOT NULL OR lst.sc IS NOT NULL OR rdg.lev IS NOT NULL OR rdg.sc IS NOT NULL OR
    			      spk.lev IS NOT NULL OR spk.sc IS NOT NULL OR wrt.lev IS NOT NULL OR wrt.sc IS NOT NULL OR
                tot.lev IS NOT NULL OR tot.sc IS NOT NULL OR cmp.lev IS NOT NULL OR cmp.sc IS NOT NULL OR
                ora.lev IS NOT NULL OR ora.sc IS NOT NULL OR lrc.lev IS NOT NULL OR lrc.sc IS NOT NULL;

    -- Returns the table valued return object
    RETURN;

  -- End of the function body
  END

-- End of batch block at close of function definition
GO

-- Returns all of the ACCESS Scores for a single school year
SELECT *
FROM dbo.F_GET_ACCESS(2016, DEFAULT);
