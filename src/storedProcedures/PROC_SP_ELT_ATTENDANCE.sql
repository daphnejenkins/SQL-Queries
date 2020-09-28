/*
	Defines the procedure that will build the data needed for monthly attendance distribution files
*/

-- Tests for existence of procedure
IF OBJECT_ID('dbo.sp_elt_attendance', 'P') IS NOT NULL

		-- If already defined drop it from the database
	DROP PROCEDURE dbo.sp_elt_attendance;

	-- End of batch block
GO

-- Create the stored procedure
CREATE PROCEDURE dbo.sp_elt_attendance

  AS

  -- Drops the table if currently exists
  IF OBJECT_ID('dbo.elt_attendance_raw', 'U') IS NOT NULL
	      DROP TABLE dbo.elt_attendance_raw;

	  -- Drops the table if currently exists
  IF OBJECT_ID('dbo.elt_attendance', 'U') IS NOT NULL
	      DROP TABLE dbo.elt_attendance;

	 -- Defines the table that will house the raw data used to build the cube
 CREATE TABLE dbo.elt_attendance_raw (
	    schid VARCHAR(6) NOT NULL,
	    pid INT,
	    schyr INT NOT NULL,
	    sasid VARCHAR(15) NOT NULL,
	    stdid VARCHAR(15),
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
	    refugee BIT,
	    cadre VARCHAR(MAX),
	    schperiod TINYINT NOT NULL,
	    daysenr DOUBLE PRECISION,
	    present DOUBLE PRECISION,
	    absent DOUBLE PRECISION,
	    pctattendance DOUBLE PRECISION
	  );

	  -- Defines the table that will store the CUBE results
  CREATE TABLE dbo.elt_attendance (
	    schnm        VARCHAR(50) NOT NULL,
	    cadre        VARCHAR(50),
	    schperiod    TINYINT,
	    grade        TINYINT,
	    sex          BIT,
	    race         TINYINT,
	    swd          BIT,
	    ell          BIT,
	    frl          TINYINT,
	    tag          TINYINT,
	    hhm          BIT,
	    nstudents    INTEGER,
	    mudaysenr    DOUBLE PRECISION,
	    sigmadaysenr DOUBLE PRECISION,
	    mupresent    DOUBLE PRECISION,
	    sigmapresent DOUBLE PRECISION,
	    muabsent     DOUBLE PRECISION,
	    sigmaabsent  DOUBLE PRECISION,
	    muada        DOUBLE PRECISION,
	    sigmaada     DOUBLE PRECISION
	  );

	  -- Declares the date paramters used in the queries that follow to construct the appropriate
  -- periods of data
  DECLARE @start1 DATE, @start2 DATE, @start3 DATE, @end1 DATE, @end2 DATE, @end3 DATE;

  -- Set each of the parameters using the results from the F_ELTMONTHS function
  SET @start1 = (SELECT sdate
	                 FROM dbo.F_ELTMONTHS(DATEPART(m, DATEADD(m, -1, GETDATE())),
				                                      DATEPART(yyyy, GETDATE()))
							                 WHERE dtype = 1);
								  SET @start2 = (SELECT sdate
									                 FROM dbo.F_ELTMONTHS(DATEPART(m, DATEADD(m, -1, GETDATE())),
												                                      DATEPART(yyyy, GETDATE()))
															                 WHERE dtype = 2);
																  SET @start3 = (SELECT sdate
																	                 FROM dbo.F_ELTMONTHS(DATEPART(m, DATEADD(m, -1, GETDATE())),
																				                                      DATEPART(yyyy, GETDATE()))
																							                 WHERE dtype = 3);
																								  SET @end1 = 	(SELECT edate
																									                 FROM dbo.F_ELTMONTHS(DATEPART(m, DATEADD(m, -1, GETDATE())),
																												                                      DATEPART(yyyy, GETDATE()))
																															                 WHERE dtype = 1);
																																  SET @end2 = 	(SELECT edate
																																	                 FROM dbo.F_ELTMONTHS(DATEPART(m, DATEADD(m, -1, GETDATE())),
																																				                                      DATEPART(yyyy, GETDATE()))
																																							                 WHERE dtype = 2);
																																								  SET @end3 = 	(SELECT edate
																																									                 FROM dbo.F_ELTMONTHS(DATEPART(m, DATEADD(m, -1, GETDATE())),
																																												                                      DATEPART(yyyy, GETDATE()))
																																															                 WHERE dtype = 3);

																																																   -- Subquery to construct the raw data used to build the cube for the distribution files
  WITH aggData AS (
	    SELECT a.*, 1 AS period,
	           b.daysenr, b.present, b.absent,
		           ROUND(100 * CAST(b.present AS NUMERIC)/CAST(b.daysenr  AS NUMERIC), 2) AS pctattendance
			    FROM dbo.F_DEMO_ENROLL(@start1, @end1) AS a,
			    (SELECT atnd.personID, COUNT(atnd.personID) AS daysenr, SUM(atnd.truancyPresent) AS present, SUM(atnd.truancyAbsent) AS absent
				       FROM [fcps_jrm_jrb].[dbo].[attendancedaily] AS atnd
				       WHERE atnd.date BETWEEN @start1 AND @end1
				       GROUP BY atnd.personID) AS b
			    WHERE a.pid = b.personID

			    UNION ALL

			    SELECT c.*, 2 AS period,
			           d.daysenr, d.present, d.absent,
				      ROUND(100 * CAST(d.present AS NUMERIC)/CAST(d.daysenr AS NUMERIC), 2) AS pctattendance
				    FROM dbo.F_DEMO_ENROLL(@start2, @end2) AS c,
				    (SELECT atnd.personID, COUNT(atnd.personID) AS daysenr, SUM(atnd.truancyPresent) AS present, SUM(atnd.truancyAbsent) AS absent
					       FROM [fcps_jrm_jrb].[dbo].[attendancedaily] AS atnd
					       WHERE atnd.date BETWEEN @start2 AND @end2
					       GROUP BY atnd.personID) AS d
				    WHERE c.pid = d.personID

				    UNION ALL

				    SELECT e.*, 3 AS period,
				           f.daysenr, f.present, f.absent,
					          ROUND(100 * CAST(f.present AS NUMERIC)/CAST(f.daysenr AS NUMERIC), 2) AS pctattendance
						    FROM dbo.F_DEMO_ENROLL(@start3, @end3) AS e,
						    (SELECT atnd.personID, COUNT(atnd.personID) AS daysenr, SUM(atnd.truancyPresent) AS present, SUM(atnd.truancyAbsent) AS absent
							       FROM [fcps_jrm_jrb].[dbo].[attendancedaily] AS atnd
							       WHERE atnd.date BETWEEN @start3 AND @end3
							       GROUP BY atnd.personID) AS f
						    WHERE e.pid = f.personID
						  )
						  INSERT dbo.elt_attendance_raw (schid, pid, schyr, sasid, stdid, firstnm, mi, lastnm, dob, schnm,
							                  sdate, edate, grade, sex, race, swd, ell, usentry, frl, tag, gap, hhm,
									                  migrant, section504, immigrant, refugee, cadre, schperiod, daysenr, present,
											                  absent, pctattendance)
												  SELECT schid, pid, schyr, sasid, stdid, firstnm, mi, lastnm, dob, schnm, sdate, edate, grade, sex, race, swd, ell,
												  usentry, frl, tag, gap, hhm, migrant, section504, immigrant, refugee, dbo.F_GET_DIRECTOR(schnm) AS cadre, period AS schperiod,
												    daysenr, present, absent, pctattendance
												  FROM aggData;

												  -- Inserts the results from the CUBE into the table used to store the aggregate results
  INSERT dbo.elt_attendance (schnm, cadre, schperiod, grade, sex, race, swd, ell, frl, tag, hhm, nstudents,
	                      mudaysenr, sigmadaysenr, mupresent, sigmapresent, muabsent, sigmaabsent,
			                      muada, sigmaada)
				  SELECT CASE
				        WHEN (GROUPING(schnm) = 1) THEN 'Fayette County Public Schools'
						        ELSE ISNULL(schnm, '')
								      END AS schnm,
								      cadre,
								    schperiod AS period,
								    grade,
								    sex,
								    race,
								    swd,
								    ell,
								    frl,
								    tag,
								    hhm,
								    COUNT(pid) AS nstudents,                                                    -- Number of students
								    AVG(daysenr) AS mudaysenr,                                                  -- Average number of days enrolled
								    STDEV(daysenr) AS sigmadaysenr,                                             -- SD days enrolled
								    AVG(present) AS mupresent,                                                  -- Average number of days presents
								    STDEV(present) AS sigmapresent,                                             -- SD Days present
								    AVG(absent) AS muabsent,                                                    -- Average days absent
								    STDEV(absent) AS sigmaabsent,                                               -- SD Days absent
								    AVG(pctattendance) AS muada,                                                -- Average daily attendance
								    STDEV(pctattendance) AS sigmaada                                            -- SD for daily attendance rate
								  FROM dbo.elt_attendance_raw
								  GROUP BY CUBE(schnm, cadre, schperiod, grade, sex, race, swd, ell, frl, tag, hhm)
								  HAVING schperiod IS NOT NULL
								  ORDER BY 1 ASC, 2 ASC, 3 ASC;

								  -- Get rid of the source data table to reduce disk consumption
  DROP TABLE dbo.elt_attendance_raw;

GO


