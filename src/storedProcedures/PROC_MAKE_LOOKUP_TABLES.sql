-- Tests whether or not the stored procedure exists in the database
IF EXISTS ( SELECT *
            FROM   sysobjects
            WHERE  id = object_id(N'[dbo].[proc_make_lookup_tables]')
                   and OBJECTPROPERTY(id, N'IsProcedure') = 1 )

  -- Drops the procedure if it exists                 
  DROP PROCEDURE dbo.proc_make_lookup_tables;

-- End of the first batch/block of code
GO

-- Defines a stored procedure used to build a series of look up tables 
-- to be used in conjunction with the dbo.F_DEMO_ENROLL function
CREATE PROCEDURE dbo.proc_make_lookup_tables AS

  -- Starts the body of the stored procedure
  BEGIN

    -- Tests whether or not it is necessary to drop the Ethnoracial Identity lookup table
    IF OBJECT_ID(N'dbo.race', N'U') IS NOT NULL 
      DROP TABLE dbo.race;

    -- Tests whether or not it is necessary to drop the Student Sex lookup table
    IF OBJECT_ID(N'dbo.sex', N'U') IS NOT NULL 
      DROP TABLE dbo.sex;

    -- Tests whether or not it is necessary to drop the Students with Disabilities lookup table
    IF OBJECT_ID(N'dbo.swd', N'U') IS NOT NULL 
      DROP TABLE dbo.swd;

    -- Tests whether or not it is necessary to drop the English Learners lookup table
    IF OBJECT_ID(N'dbo.ell', N'U') IS NOT NULL 
      DROP TABLE dbo.ell;

    -- Tests whether or not it is necessary to drop the Free/Reduced Price Lunch lookup table
    IF OBJECT_ID(N'dbo.frl', N'U') IS NOT NULL 
      DROP TABLE dbo.frl;

    -- Tests whether or not it is necessary to drop the Gifted/Talented lookup table
    IF OBJECT_ID(N'dbo.tag', N'U') IS NOT NULL 
      DROP TABLE dbo.tag;

    -- Tests whether or not it is necessary to drop the GAP Group lookup table
    IF OBJECT_ID(N'dbo.gap', N'U') IS NOT NULL 
      DROP TABLE dbo.gap;

    -- Tests whether or not it is necessary to drop the Homeless/Highly Mobile lookup table
    IF OBJECT_ID(N'dbo.hhm', N'U') IS NOT NULL 
      DROP TABLE dbo.hhm;

    -- Tests whether or not it is necessary to drop the Migrant Family lookup table
    IF OBJECT_ID(N'dbo.migrant', N'U') IS NOT NULL 
      DROP TABLE dbo.migrant;

    -- Tests whether or not it is necessary to drop the Section 504 Plan lookup table
    IF OBJECT_ID(N'dbo.section504', N'U') IS NOT NULL 
      DROP TABLE dbo.section504;

    -- Tests whether or not it is necessary to drop the Immigrant Status lookup table
    IF OBJECT_ID(N'dbo.immigrant', N'U') IS NOT NULL 
      DROP TABLE dbo.immigrant;

    -- Tests whether or not it is necessary to drop the Refugee Status lookup table
    IF OBJECT_ID(N'dbo.refugee', N'U') IS NOT NULL 
      DROP TABLE dbo.refugee;

    -- Tests whether or not it is necessary to drop the Grade Level lookup table
    IF OBJECT_ID(N'dbo.grade', N'U') IS NOT NULL 
      DROP TABLE dbo.grade;

    -- Defines the structure for the Ethnoracial Identity table
    CREATE TABLE dbo.race (
      id TINYINT PRIMARY KEY,
      label VARCHAR(50) NOT NULL,
      shrt VARCHAR(25) NOT NULL,
      alt VARCHAR(100),
      fed VARCHAR(100)
    );

    -- Defines the structure for the Student Sex table
    CREATE TABLE dbo.sex (
      id BIT PRIMARY KEY,
      label VARCHAR(50) NOT NULL,
      shrt VARCHAR(25) NOT NULL,
      alt VARCHAR(100),
      fed VARCHAR(100)
    );

    -- Defines the structure for the Students with Disabilities table
    CREATE TABLE dbo.swd (
      id BIT PRIMARY KEY,
      label VARCHAR(50) NOT NULL,
      shrt VARCHAR(25) NOT NULL,
      alt VARCHAR(100),
      fed VARCHAR(100)
    );

    -- Defines the structure for the English Learners table
    CREATE TABLE dbo.ell (
      id BIT PRIMARY KEY,
      label VARCHAR(50) NOT NULL,
      shrt VARCHAR(25) NOT NULL,
      alt VARCHAR(100),
      fed VARCHAR(100)
    );

    -- Defines the structure for the Free/Reduced Price Lunch table
    CREATE TABLE dbo.frl (
      id TINYINT PRIMARY KEY,
      label VARCHAR(50) NOT NULL,
      shrt VARCHAR(25) NOT NULL,
      alt VARCHAR(100),
      fed VARCHAR(100)
    );

    -- Defines the structure for the Gifted/Talented table
    CREATE TABLE dbo.tag (
      id TINYINT PRIMARY KEY,
      label VARCHAR(50) NOT NULL,
      shrt VARCHAR(25) NOT NULL,
      alt VARCHAR(100),
      fed VARCHAR(100)
    );

    -- Defines the structure for the Homeless/Highly Mobile table
    CREATE TABLE dbo.hhm (
      id BIT PRIMARY KEY,
      label VARCHAR(50) NOT NULL,
      shrt VARCHAR(25) NOT NULL,
      alt VARCHAR(100),
      fed VARCHAR(100)
    );

    -- Defines the structure for the Migrant Family table
    CREATE TABLE dbo.migrant (
      id TINYINT PRIMARY KEY,
      label VARCHAR(50) NOT NULL,
      shrt VARCHAR(25) NOT NULL,
      alt VARCHAR(100),
      fed VARCHAR(100)
    );

    -- Defines the structure for the Section 504 Plan table
    CREATE TABLE dbo.section504 (
      id BIT PRIMARY KEY,
      label VARCHAR(50) NOT NULL,
      shrt VARCHAR(25) NOT NULL,
      alt VARCHAR(100),
      fed VARCHAR(100)
    );

    -- Defines the structure for the Immigrant Status table
    CREATE TABLE dbo.immigrant (
      id BIT PRIMARY KEY,
      label VARCHAR(50) NOT NULL,
      shrt VARCHAR(25) NOT NULL,
      alt VARCHAR(100),
      fed VARCHAR(100)
    );

    -- Defines the structure for the refugee status table
    CREATE TABLE dbo.refugee (
      id BIT PRIMARY KEY,
      label VARCHAR(50) NOT NULL,
      shrt VARCHAR(25) NOT NULL,
      alt VARCHAR(100),
      fed VARCHAR(100)
    );

    -- Defines the structure for the GAP Group table
    CREATE TABLE dbo.gap (
      id BIT PRIMARY KEY,
      label VARCHAR(50) NOT NULL,
      shrt VARCHAR(25) NOT NULL,
      alt VARCHAR(100),
      fed VARCHAR(100)
    );

    -- Defines the structure for the Grade level table
    CREATE TABLE dbo.grade (
      id TINYINT PRIMARY KEY,
      label VARCHAR(50) NOT NULL,
      shrt VARCHAR(25) NOT NULL,
      alt VARCHAR(100),
      fed VARCHAR(100)
    );

    -- Loads the lookup values into the Ethnoracial Identity table
    INSERT dbo.race
    VALUES  (1, 'Hispanic', 'His', 'Hispanic/Latino(a)', 'HI7'),
            (2, 'American Indian or Alaska Native', 'Ind', 'First Nations', 'AM7'),
            (3, 'Asian', 'Asi', 'Asian', 'AS7'),
            (4, 'African American', 'Blk', 'Black', 'BL7'),
            (5, 'Native Hawaiian or Other Pacific Island', 'Isl', 'Pacific Islander', 'PI7'),
            (6, 'White (Non-Hispanic)', 'Wht', 'White', 'WH7'),
            (7, 'Two or more races', 'Oth', 'Multiracial', 'MU7');

    -- Loads the lookup values into the Student Sex table
    INSERT dbo.sex
    VALUES (0, 'Male', 'M', 'Boy', 'M'), (1, 'Female', 'F', 'Girl', 'F');

    -- Loads the lookup values into the Students with Disabilities table
    INSERT dbo.swd
    VALUES  (0, 'No Identified Disabilities', '', 'Not Served by Special Education Program', 'WODIS'),
            (1, 'Disability-With IEP (Total)', 'Yes', 'Served by Special Education Program', 'WDIS');

    -- Loads the lookup values into the English Learner table
    INSERT dbo.ell
    VALUES  (0, 'Not an English Learner', '', 'Not Served by EL Program', 'NLEP'),
            (1, 'English Learner', 'Yes', 'Served by EL Program', 'LEP');

    -- Loads the lookup values into the Free/Reduced Price Lunch table
    INSERT dbo.frl
    VALUES  (0, 'Full-Price Meals', '', 'Not Economically Disadvantaged', ''),
            (1, 'Reduced-Price Meals', 'Yes', 'Economically Disadvantaged', 'ECODIS'),
            (2, 'Free Meals', 'Yes', 'Economically Disadvantaged', 'ECODIS');

    -- Loads the lookup values into the Gifted/Talented table
    INSERT dbo.tag
    VALUES  (0, 'General Education', '',      'General Ed', ''),
            (1, 'Primary Talent Pool', 'Yes', 'Gifted/Talented', 'G/T'),
            (2, 'Gifted/Talented', 'Yes',     'Gifted/Talented', 'G/T');

    -- Loads the lookup values into the Homeless/Highly Mobile table
    INSERT dbo.hhm
    VALUES  (0, 'Stable Housing',         '',    'Stable Housing', ''),
            (1, 'Homeless/Highly Mobile', 'Yes', 'Instable Housing', 'HOMELSENRL');

    -- Loads the lookup values into the Migrant Family table
    INSERT dbo.migrant
    VALUES  (0, 'Non-Migrant Family Student',        '',         'Not Migrant', ''),
            (1, 'Migrant Family Student - Inactive', 'Inactive', 'Was Migrant', 'MS'),
            (2, 'Migrant Family Student - Active',   'Active',    'Is Migrant', 'MS');

    -- Loads the lookup values into the Section 504 Plan table
    INSERT dbo.section504
    VALUES  (0, 'Does Not Have a 504 Plan', '',    'Not 504', ''),
            (1, 'Has a 504 Plan',           'Yes', 'Is 504', 'DISAB504STAT');

    -- Loads the lookup values into the Immigrant Status table
    INSERT dbo.immigrant
    VALUES  (0, 'Not an Immigrant', '',    'Non-Immigrant', ''),
            (1, 'Immigrant',     'Yes', 'Immigrant', 'PART');


    -- Loads the lookup values into the Refugee Status table
    INSERT dbo.refugee
    VALUES  (0, 'Not a Refugee',  '',  'Non-Refugee', ''),
            (1, 'Refugee',      'Yes', 'Refugee', '');

    -- Loads the lookup values into the GAP Group table
    INSERT dbo.gap
    VALUES (0, 'Not in Gap Group',           '',    'Not Gap', ''),
           (1, 'Gap Group (non-duplicated)', 'Yes', 'Is Gap', 'GAP');

    -- Loads the lookup values into the Grade level table
    INSERT dbo.grade
    VALUES (0, 'Kindergarten', 'K', 'Kinder', 'KG'),
      (1, '1st Grade', '01', 'Gr. 1', '01'),
      (2, '2nd Grade', '02', 'Gr. 2', '02'),
      (3, '3rd Grade', '03', 'Gr. 3', '03'),
      (4, '4th Grade', '04', 'Gr. 4', '04'),
      (5, '5th Grade', '05', 'Gr. 5', '05'),
      (6, '6th Grade', '06', 'Gr. 6', '06'),
      (7, '7th Grade', '07', 'Gr. 7', '07'),
      (8, '8th Grade', '08', 'Gr. 8', '08'),
      (9, '9th Grade', '09', 'Gr. 9', '09'),
      (10, '10th Grade', '10', 'Gr. 10', '10'),
      (11, '11th Grade', '11', 'Gr. 11', '11'),
      (12, '12th Grade', '12', 'Gr. 12', '12'),
      (14, 'IDEA Extension', '14', 'IDEA', 'UG'),
      (97, 'Pre-K', '97', 'ECE', 'PK'),
      (98, 'Pre-K', '98', 'ECE', 'PK'),
      (99, 'Pre-K', '99', 'ECE', 'PK');


  -- End of the stored procedure definition
  END;

-- End of the batch
GO

-- Execute the stored procedure
EXEC dbo.proc_make_lookup_tables ;