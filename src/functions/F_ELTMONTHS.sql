/***********************************************************************************************************************
*                                                                                                                      *
* Title: F_ELTMONTHS                                                                                                   *
*                                                                                                                      *
*  Description: Function used to get an "array" of dates based on requested periods from ELT (e.g., current month,     *
*               year-to-date, and current month from previous year).                                                   *
*                                                                                                                      *
*  Parameters:                                                                                                         *
*                                                                                                                      *
*      @mnth - The numeric month on which the results should be based.                                                 *
*      @yr - The numeric year on which the results should be based (this should be the year for the current month      *
*            option)                                                                                                   *
*                                                                                                                      *
*  Return values:                                                                                                      *
*                                                                                                                      *
*      dtype - 1 = Year to Date; 2 = Current Month/Year; 3 = Current Month/Prior Year                                  *
*      sdate - Opening of the date window                                                                              *
*      edate - Closing of the date window                                                                              *
*                                                                                                                      *
*  Example:                                                                                                            *
*                                                                                                                      *
*      SELECT *                                                                                                        *
*      FROM F_ELTMONTHS(2, 2017);                                                                                      *
*                                                                                                                      *
*                                                                                                                      *
*      dtype | sdate      | edate                                                                                      *
*      1     | 2016-07-01 | 2017-02-28                                                                                 *
*      2     | 2017-02-01 | 2017-02-28                                                                                 *
*      3     | 2016-02-01 | 2016-02-29                                                                                 *
*                                                                                                                      *
***********************************************************************************************************************/

-- Drops the function if it is already defined in the database/schema
IF object_id('F_ELTMONTHS', 'TF') IS NOT NULL
    DROP FUNCTION [dbo].F_ELTMONTHS;
GO

-- Defines the function F_ELTMONTHS
CREATE FUNCTION dbo.F_ELTMONTHS(@mnth TINYINT, @yr SMALLINT)

  -- Declares the return type of the table
  RETURNS @thedates TABLE (
    dtype TINYINT PRIMARY KEY,
    sdate DATE NOT NULL,
    edate DATE NOT NULL
  ) AS

  -- Begins the body of the function
  BEGIN

    -- Declares a variable used to define the first starting date
    DECLARE @sdate1 AS DATE;

    -- Declares a variable used to define the second starting date
    DECLARE @sdate2 AS DATE;

    -- Declares a variable used to define the third starting date
    DECLARE @sdate3 AS DATE;

    -- Variable used to handle dates in the second half of the academic year
    DECLARE @yroffset AS SMALLINT;

    -- Offsets the academic year to get the correct value for the year to date year by subtracting 1
    IF @mnth BETWEEN 1 AND 6 SET @yroffset = @yr - 1;

    -- Otherwise uses the year passed by end user
    ELSE SET @yroffset = @yr;

    -- Sets the value of the first starting date to the start of the fiscal year
    SET @sdate1 = (SELECT CAST('07/01/' + CAST(@yroffset AS VARCHAR(4)) AS DATE));

    -- Sets the value of the second starting date to the first day of the provided month and year
    SET @sdate2 = (SELECT CAST(
                                CAST(
                                      CAST(@mnth AS VARCHAR(2)) + '/01/' + CAST(@yr AS VARCHAR(4))
                                AS VARCHAR(10))
                          AS DATE));

    -- Sets the value of the third starting date to the value of @sdate2 - 1 year
    SET @sdate3 = (SELECT DATEADD(year, -1, @sdate2));

    -- Insert values into the table @thedates
    INSERT @thedates

      -- Defines the values to insert into the table
      VALUES
              -- First starting date with the ending based on the second starting date to construct year to date
              (1, @sdate1, EOMONTH(@sdate2)),

              -- Second starting date used to set first and last day of the current month
              (2, @sdate2, EOMONTH(@sdate2)),

              -- Third starting date used to set the first and last year of the month from the previous year
              (3, @sdate3, EOMONTH(@sdate3));

    -- Returns the table variable
    RETURN;

  -- End of the function body
  END;

-- End of the function declaration
GO


SELECT *
FROM dbo.F_ELTMONTHS(2, 2017);