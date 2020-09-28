
-- Tests whether the function is currently built on the data base
IF object_id(N'dbo.F_DEMO_ENROLL', N'TF') IS NOT NULL

	-- If the function exists drop it before redefining it
    DROP FUNCTION dbo.F_DEMO_ENROLL;

-- End of batch block
GO

-- Defines function to return demographics and enrollmnent data for
-- Students based on a user specified enrollment window
CREATE FUNCTION dbo.F_DEMO_ENROLL(@start DATE, @end DATE)

	-- Defines the table structure that will be returned by the function
	RETURNS @retval TABLE (
			schid VARCHAR(6) NOT NULL,
			pid INT PRIMARY KEY,
			schyr INT NOT NULL,
			sasid VARCHAR(15) NOT NULL,
			stdid VARCHAR(15),
			-- hhid INT NOT NULL,
			firstnm VARCHAR(50) NOT NULL,
			mi VARCHAR(1),
			lastnm VARCHAR(50) NOT NULL,
			dob DATE NOT NULL,
			schnm VARCHAR(50) NOT NULL,
			sdate DATE NOT NULL,
			edate DATE,
			grade TINYINT,
			sex BIT,
			race TINYINT,
			swd BIT,
			ell BIT,
			usentry DATE,
			frl TINYINT,
			tag TINYINT,
			gap BIT,
			hhm BIT,
			migrant TINYINT,
			section504 BIT,
			immigrant BIT,
			refugee BIT
		) AS

	-- Starts the body of the function
	BEGIN

    -- Insert the data into the table variable that will be returned by this function
		INSERT @retval (schid, pid, schyr, sasid, stdid, firstnm, mi, lastnm, dob, schnm, sdate,
						edate, grade, sex, race, swd, ell, usentry, frl, tag, gap, hhm,
						migrant, section504, immigrant, refugee)

		-- Selects the data that will be inserted into the table variable
		SELECT DISTINCT b.schid, b.pid, b.schyr, b.sasid, b.stdid, -- b.hhid,
						b.firstnm, b.mi, b.lastnm, b.dob, b.schnm,
					 	b.sdate, b.edate, b.grade, b.sex, b.race, b.swd, b.ell, b.usentry, b.frl, b.tag,
					-- Business logic for the gap group
					CAST(CASE
						WHEN b.race IN ('White (Non-Hispanic)', 'Native Hawaiian or Other Pacific Island', 'Asian') AND
								 b.swd IS NULL AND b.ell IS NULL AND b.frl = 'Full-Price Meals'
						THEN 0
						ELSE 1
					END AS BIT) AS gap,
          			b.hhm, b.migrant, b.section504, b.immigrant, b.refugee

		-- This is the query where the demographics and all that are selected
		FROM ( SELECT DISTINCT 	'165' + LTRIM(RTRIM(s.number)) AS schid,
									p.personid AS pid,
      								FCPS_BB.dbo.F_ENDYEAR(y.sdate, DEFAULT) AS schyr,
									p.stateID AS sasid,
									p.studentNumber AS stdid,
									-- h.householdID AS hhid,
									i.firstName AS firstnm,
									SUBSTRING(i.middleName, 1, 1) AS mi,
									i.lastName AS lastnm,
									CAST(i.birthdate AS DATE) AS dob,
									s.name AS schnm,
									CAST(y.sdate AS DATE) AS sdate,
			            			CAST(y.edate AS DATE) AS edate,
									CAST(e.grade AS TINYINT) AS grade,
									CAST(CASE
											WHEN i.gender = 'M' THEN 0
											WHEN i.gender = 'F' THEN 1
											ELSE NULL
										END AS BIT) AS sex,
									i.raceEthnicityFed AS race,
									CAST(CASE
											WHEN (e.specialEdStatus IN ('A', 'AR') OR
												 (e.specialEdStatus = 'I' AND e.spedExitDate BETWEEN e.startDate AND e.endDate))
											THEN 1
											ELSE 0
										END AS BIT) AS swd,
									CAST(CASE
											WHEN l.lepID IS NOT NULL THEN 1
											ELSE 0
										END AS BIT) AS ell,
									CAST(i.dateEnteredUS AS DATE) AS usentry,
									CASE
										WHEN pe.frl IS NULL THEN 0
										ELSE pe.frl
									END AS frl,
									CAST(CASE
											WHEN g.giftedID IS NOT NULL AND g.category = '12' THEN 1
											WHEN g.giftedID IS NOT NULL THEN 2
											ELSE 0
										END AS TINYINT) AS tag,
									CAST(CASE
					                        WHEN e.homeless = 1 THEN 1
					                        ELSE 0
					                    END AS BIT) AS hhm,
									CAST(CASE
				                          	WHEN e.migrant IS NULL THEN 0
				                          	ELSE e.migrant
				                       	 END AS TINYINT) AS migrant,
									CAST(CASE
				                          	WHEN e.section504 IS NULL THEN 0
				                          	ELSE 1
				                       	 END AS BIT) AS section504,
									CAST(CASE
				                          	WHEN e.immigrant IS NULL THEN 0
				                          	ELSE 1
				                       	 END AS BIT) AS immigrant,
									CAST(CASE
				                          	WHEN eky.refugee IS NULL THEN 0
				                          	ELSE 1
				                       	 END  AS BIT) AS refugee

				FROM 				[fayette].[dbo].[Person] p
				INNER JOIN 			[fayette].[dbo].[Identity] i 					ON 	i.identityID = p.currentIdentityID
				INNER JOIN 			[fayette].[dbo].[Enrollment] e 					ON 	p.personID = e.personID AND
					                                                                    ISNULL(e.noShow, 0) = 0 AND
					                                                                    ISNULL(e.stateExclude, 0) = 0 AND
					                                                                    e.serviceType = 'p' AND 
					                                                                    e.active = 1 
				INNER JOIN 			[fayette].[dbo].[Calendar] c 				 	ON 	e.calendarID = c.calendarID
				INNER JOIN			[fayette].[dbo].[EnrollmentKY] eky 				ON 	e.personID = eky.personID AND
					                                                                    c.calendarID = eky.calendarID AND
					                                                                    e.enrollmentID = eky.enrollmentID
		    --Max Enrollment for School
		    INNER JOIN (SELECT 		e.personID, MAX(e.startDate) AS sdate,
			                  		MAX(NULLIF(e.endDate, @end)) AS edate
              			FROM 		[fayette].[dbo].[Enrollment] e WITH ( NOLOCK )
              			WHERE 		ISNULL(e.noShow, 0) = 0 AND ISNULL(e.stateExclude, 0) = 0 AND
                  					e.serviceType = 'p' AND e.startDate <= @end AND
                  					ISNULL(e.endDate, @end) >= @start AND
                  					e.endYear = FCPS_BB.dbo.F_ENDYEAR(@end, DEFAULT)
			              			GROUP BY e.personID) y 							ON 	e.personID = y.personID AND
			              																e.startDate = y.sdate

				INNER JOIN 			[fayette].[dbo].[School] s 	 					ON 	c.schoolID = s.schoolID

				--Gets English Language Learner Indicator
				LEFT JOIN 		[fayette].[dbo].[Lep] l  							ON 	p.personID = l.personID AND
					                                                                    ((l.programStatus = 'LEP' AND
					                                                                      (l.exitDate > e.startDate OR l.exitDate IS NULL)) OR
					                                                                    (l.programStatus = 'Exited LEP' AND
					                                                                      (l.exitDate BETWEEN e.startDate AND
					                                                                      ISNULL(e.endDate, @end) OR
					                                                                      l.exitDate > e.endDate)))

				--Free/Reduced Price Lunch Indicator
				--Based on conversation w/Jessica Whisman on 05dec2016 the latest status entered into the system
				--should always be returned as record with the current true status.
				LEFT JOIN ( SELECT 	personID,
									CAST(CASE
										WHEN eligibility = 'F' THEN 2
										WHEN eligibility = 'R' THEN 1
										ELSE 0
									END AS TINYINT) AS frl,
									ROW_NUMBER() OVER(PARTITION BY personID ORDER BY startDate DESC) AS recordID
							FROM [fayette].[dbo].[POSEligibility]
							WHERE endYear = dbo.F_ENDYEAR(@end, DEFAULT) AND startDate <= @end AND
								  NULLIF(endDate, @end) >= @start) AS pe ON pe.personID = p.personID AND pe.recordID = 1

				/*FRED at the beginning of the year is very tricky due to files not being loaded
				until after the year starts and not being able to backdate some things - Dana has more
				info. */
				--GT --category 12 is Primary Talent Pool - Decide to include or not depending on need
				LEFT JOIN [fayette].[dbo].[GiftedStatusKY] g 					  ON 	g.personID = p.personID AND
														 								g.endDate IS NULL

				-- LEFT JOIN [fayette].[dbo].[HouseholdMember] h 					  ON 	h.personID = p.personID

				WHERE 	e.endYear = FCPS_BB.dbo.F_ENDYEAR(@end, DEFAULT) AND
						    e.grade IN (00, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 14) AND
						    e.startDate <= @end AND ISNULL(e.endDate, @end) >= @start
				) AS b;

    -- Returns the table
    RETURN;

	-- End of the function body
	END

-- End of the batch block
GO

-- Example use case
SELECT a.*
FROM dbo.F_DEMO_ENROLL('11/01/2015', '11/30/2015') AS a;

