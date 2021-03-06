IF object_id(N'dbo.F_DEMO_ENROLL', N'TF') IS NOT NULL
    DROP FUNCTION dbo.F_DEMO_ENROLL;

GO

CREATE FUNCTION dbo.F_DEMO_ENROLL(@start DATE, @end DATE)

	RETURNS @retval TABLE (
			schid VARCHAR(6) NOT NULL,
			pid INT PRIMARY KEY,
      schyr INT NOT NULL,
			sasid VARCHAR(15) NOT NULL,
			firstnm VARCHAR(50) NOT NULL,
			mi VARCHAR(1),
			lastnm VARCHAR(50) NOT NULL,
			dob DATE NOT NULL,
			schnm VARCHAR(50) NOT NULL,
      sdate DATE NOT NULL,
      edate DATE,
			grade VARCHAR(2),
			sex VARCHAR(6),
			race VARCHAR(39),
			swd VARCHAR(27),
			ell VARCHAR(15),
			usentry DATE,
			frl VARCHAR(24),
			tag VARCHAR(19),
			gap VARCHAR(26),
      hhm VARCHAR(23)
		) AS

	BEGIN

		INSERT @retval (schid, pid, schyr, sasid, firstnm, mi, lastnm, dob, schnm, sdate,
										edate, grade, sex, race, swd, ell, usentry, frl, tag, gap, hhm)
		SELECT b.schid, b.pid, b.schyr, b.sasid, b.firstnm, b.mi, b.lastnm, b.dob, b.schnm,
					 b.sdate, b.edate, b.grade, b.sex, b.race, b.swd, b.ell, b.usentry, b.frl, b.tag,
					 b.gap, b.hhm
		FROM (
			SELECT 	a.*,
					CASE
						WHEN a.race IN ('White (Non-Hispanic)', 'Native Hawaiian or Other Pacific Island', 'Asian') AND
								 a.swd IS NULL AND a.ell IS NULL AND a.frl = 'Full-Price Meals'
						THEN NULL
						ELSE 'Gap Group (non-duplicated)'
					END AS gap
			FROM (SELECT DISTINCT '165' + LTRIM(RTRIM(s.number)) AS schid,
							p.personid AS pid,
              FCPS_BB.dbo.F_ENDYEAR(y.sdate, DEFAULT) AS schyr,
							p.stateID AS sasid,
							i.firstName AS firstnm,
							SUBSTRING(i.middleName, 1, 1) AS mi,
							i.lastName AS lastnm,
							CAST(i.birthdate AS DATE) AS dob,
							s.name AS schnm,
              CAST(y.sdate AS DATE) AS sdate,
              CAST(y.edate AS DATE) AS edate,
							e.grade,
							CASE
								WHEN i.gender = 'M' THEN 'Male'
								WHEN i.gender = 'F' THEN 'Female'
								ELSE NULL
							END                          AS sex,
							CASE
								WHEN i.raceEthnicityFed = 1 THEN 'Hispanic'
								WHEN i.raceEthnicityFed = 2 THEN 'American Indian or Alaska Native'
								WHEN i.raceEthnicityFed = 3 THEN 'Asian'
								WHEN i.raceEthnicityFed = 4 THEN 'African American'
								WHEN i.raceEthnicityFed = 5 THEN 'Native Hawaiian or Other Pacific Island'
								WHEN i.raceEthnicityFed = 6 THEN 'White (Non-Hispanic)'
								ELSE 'Two or more races'
							END AS race,
							CASE
								WHEN (e.specialEdStatus IN ('A', 'AR') OR
									 (e.specialEdStatus = 'I' AND e.spedExitDate BETWEEN e.startDate AND e.endDate))
								THEN 'Disability-With IEP (Total)'
								ELSE NULL
							END AS swd,
							CASE
								WHEN l.lepID IS NOT NULL THEN 'English Learner'
								ELSE NULL
							END AS ell,
							CAST(i.dateEnteredUS AS DATE) AS usentry,
							CASE
								WHEN pe.eligibility IS NOT NULL THEN 'Free/Reduced-Price Meals'
								ELSE 'Full-Price Meals'
							END AS frl,
							CASE
								WHEN g.giftedID IS NOT NULL AND g.category = '12' THEN 'Primary Talent Pool'
								WHEN g.giftedID IS NOT NULL THEN 'Gifted/Talented'
								ELSE NULL
							END AS tag,
              CASE
                WHEN e.homeless = 1 THEN 'Homeless/Highly Mobile'
                ELSE 'Stable Housing'
              END AS hhm
				FROM 					[fayette].[dbo].[Person] p WITH ( NOLOCK )
				INNER JOIN 		[fayette].[dbo].[Identity] i WITH ( NOLOCK )	ON 	i.identityID = p.currentIdentityID
				INNER JOIN 		[fayette].[dbo].[Enrollment] e WITH ( NOLOCK )	ON 	p.personID = e.personID AND
																						ISNULL(e.noShow, 0) = 0 AND
																						ISNULL(e.stateExclude, 0) = 0 AND
																						e.serviceType = 'p'
				INNER JOIN 		[fayette].[dbo].[Calendar] c WITH ( NOLOCK ) 		ON 	e.calendarID = c.calendarID

        --Max Enrollment for School
        INNER JOIN (
              SELECT 	e.personID,
                  		MAX(e.startDate) AS sdate,
                  		MAX(NULLIF(e.endDate, @end)) AS edate
              FROM 	  [fayette].[dbo].[Enrollment] e WITH ( NOLOCK )
              WHERE 	ISNULL(e.noShow, 0) = 0 AND ISNULL(e.stateExclude, 0) = 0 AND
                  		e.serviceType = 'p' AND e.startDate <= @end AND
                  		ISNULL(e.endDate, @end) >= @start AND
                  		e.endYear = FCPS_BB.dbo.F_ENDYEAR(@end, DEFAULT)
              GROUP BY e.personID
          ) y ON e.personID = y.personID AND e.startDate = y.sdate

				INNER JOIN 		[fayette].[dbo].[School] s WITH ( NOLOCK ) 			ON 	c.schoolID = s.schoolID

				--Gets English Language Learner Indicator
				LEFT JOIN 		[fayette].[dbo].[Lep] l WITH ( NOLOCK ) 			ON 	p.personID = l.personID AND
																				((l.programStatus = 'LEP' AND
																					(l.exitDate > e.startDate OR l.exitDate IS NULL)) OR
																				(l.programStatus = 'Exited LEP' AND
																					(l.exitDate BETWEEN e.startDate AND
																					ISNULL(e.endDate, @end) OR
																					l.exitDate > e.endDate)))

				--Free/Reduced Price Lunch Indicator
				LEFT JOIN 	[fayette].[dbo].[POSEligibility] pe WITH (NOLOCK) 	ON 	p.personID = pe.personID AND
																				e.endYear = pe.endYear AND
																				pe.eligibility IN ('F', 'R')

				/*FRED at the beginning of the year is very tricky due to files not being loaded
				until after the year starts and not being able to backdate some things - Dana has more
				info. */
				--GT --category 12 is Primary Talent Pool - Decide to include or not depending on need
				LEFT OUTER JOIN [fayette].[dbo].[GiftedStatusKY] g 				ON 	g.personID = p.personID AND
														 						g.endDate IS NULL

				WHERE 	e.endYear = FCPS_BB.dbo.F_ENDYEAR(@end, DEFAULT) AND
								e.grade IN (00, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 14) AND
								e.startDate <= @end AND ISNULL(e.endDate, @end) BETWEEN @start AND @end
				) AS a
			) AS b;

		RETURN;

	END
GO

-- Executes an example query to use for testing purposes
SELECT *
FROM FCPS_BB.dbo.F_DEMO_ENROLL('10/01/2016', '10/31/2016');


