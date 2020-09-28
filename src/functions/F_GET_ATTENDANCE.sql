-- Checks to see if function is already defined
IF OBJECT_ID('dbo.F_GET_ATTENDANCE', 'TF') IS NOT NULL

    -- If function already exists in DB drop the function
    DROP FUNCTION dbo.F_GET_ATTENDANCE;

-- End this batch block
GO

-- Defines function used to query attendance data for students
CREATE FUNCTION dbo.F_GET_ATTENDANCE(@start DATE, @end DATE, @person INT = NULL)

  -- Defines the structure of the table object returned from the function
  RETURNS @retval TABLE (
    pid INT PRIMARY KEY,
    daysenr DOUBLE PRECISION,
    present DOUBLE PRECISION,
    absent DOUBLE PRECISION,
    pctattendance DOUBLE PRECISION
  ) AS

  -- Starts the function body
  BEGIN

    -- If no person ID is passed, pull records for all students
    IF @person IS NULL

      -- Insert the records onto the table variable
      INSERT @retval(pid, daysenr, present, absent, pctattendance)
      SELECT  atnd.personID AS pid,
              CAST(COUNT(atnd.personID) AS DOUBLE PRECISION) AS daysenr,
              CAST(SUM(atnd.truancyPresent) AS DOUBLE PRECISION) AS present,
              CAST(SUM(atnd.truancyAbsent) AS DOUBLE PRECISION) AS absent,
              ROUND((100 * (CAST(SUM(atnd.truancyPresent) AS DOUBLE PRECISION)/
                            CAST(COUNT(atnd.personID) AS DOUBLE PRECISION))), 2) AS pctattendance
      -- Selects the data from table that Jill created in her DB for attendance
      FROM [fcps_jrm_jrb].[dbo].[attendancedaily] AS atnd
      -- Select only the dates in the range passed to the function
      WHERE atnd.date BETWEEN @start AND @end
      -- Aggregate by student (personID)
      GROUP BY atnd.personID;

    -- If an individual person ID is passed to the function it uses the same logic as above, but only
    -- returns the data for that one student.
    ELSE

      INSERT @retval(pid, daysenr, present, absent, pctattendance)
      SELECT  atnd.personID AS pid,
              CAST(COUNT(atnd.personID) AS DOUBLE PRECISION) AS daysenr,
              CAST(SUM(atnd.truancyPresent) AS DOUBLE PRECISION) AS present,
              CAST(SUM(atnd.truancyAbsent) AS DOUBLE PRECISION) AS absent,
              ROUND((100 * (CAST(SUM(atnd.truancyPresent) AS DOUBLE PRECISION)/
                            CAST(COUNT(atnd.personID) AS DOUBLE PRECISION))), 2) AS pctattendance
      FROM [fcps_jrm_jrb].[dbo].[attendancedaily] AS atnd
      WHERE atnd.date BETWEEN @start AND @end AND atnd.personID = @person
      GROUP BY atnd.personID;

    -- Returns the table object
    RETURN;

  -- End of the function body
  END


-- End of the batch block
GO


-- Examples

-- Query Student attendance records for the month of January
SELECT *
FROM dbo.F_GET_ATTENDANCE('01/01/2017', '01/31/2017', DEFAULT);

-- Query student attendance records for the year to date
SELECT *
FROM dbo.F_GET_ATTENDANCE('07/01/2016', GETDATE(), DEFAULT);
