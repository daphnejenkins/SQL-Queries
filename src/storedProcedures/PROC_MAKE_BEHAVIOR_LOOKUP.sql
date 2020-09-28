-- Tests whether or not the stored procedure exists in the database
IF EXISTS ( SELECT *
            FROM   sysobjects
            WHERE  id = object_id(N'[dbo].[proc_make_behavior_lookup]')
                   and OBJECTPROPERTY(id, N'IsProcedure') = 1 )

  -- Drops the procedure if it exists
  DROP PROCEDURE dbo.proc_make_behavior_lookup;

-- End of the first batch/block of code
GO

-- Defines a stored procedure used to build a series of look up tables
-- to be used in conjunction with the dbo.F_DEMO_ENROLL function
CREATE PROCEDURE dbo.proc_make_behavior_lookup AS

  -- Starts the body of the stored procedure
  BEGIN

		-- Drops the index on the lookup table if it exists
		IF EXISTS(SELECT *
							FROM sys.indexes
							WHERE name = 'idx_behavior_siscode_lookup' AND object_id = OBJECT_ID('behaviorLookups'))
			DROP INDEX idx_behavior_siscode_lookup ON dbo.behaviorLookups;

		-- Drops the table if it already exists
    IF OBJECT_ID(N'dbo.behaviorLookups', N'U') IS NOT NULL
      DROP TABLE dbo.behaviorLookups;

		-- Defines table that will contain mappings from SIS value codes to Stata based codes
		-- Also specifies the primary key constraint should use the table name, column name, and Stata value for mapping
		CREATE TABLE dbo.behaviorLookups (
			dictid INT NOT NULL,
			attrid INT NOT NULL,
			siscode VARCHAR(15),
			stcode TINYINT NOT NULL,
			tablenm VARCHAR(20) NOT NULL,
			varnm VARCHAR(24) NOT NULL,
			varlab VARCHAR(32) NOT NULL,
			vallab VARCHAR(57),
			CONSTRAINT pk_behaviorLookup PRIMARY KEY (tablenm, varnm, stcode)
		);

		-- Creates index on the table for looking up SIS codes
		CREATE INDEX idx_behavior_siscode_lookup ON dbo.behaviorLookups(siscode);

		-- Push the data into the table using a query on the tables containing the column and metadata references
		INSERT dbo.behaviorLookups (dictid, attrid, siscode, stcode, tablenm, varnm, varlab, vallab)
		SELECT DISTINCT cd.dictionaryID AS dictid,
										cd.attributeID AS attrid,
										LTRIM(RTRIM(cd.code)) AS siscode,
										CAST(ROW_NUMBER() OVER (PARTITION BY ca.object, ca.element ORDER BY cd.code) AS TINYINT) AS stcode,
										LTRIM(RTRIM(ca.object)) AS tablenm,
										LTRIM(RTRIM(ca.element)) AS varnm,
										LTRIM(RTRIM(ca.name)) AS varlab,
										LTRIM(RTRIM(cd.name)) AS vallab
		FROM 						[fayette].[dbo].CampusAttribute AS ca,
				 						[fayette].[dbo].CampusDictionary AS cd
		WHERE 					ca.object LIKE 'Behavior%' AND
									 	ca.attributeID = cd.attributeID;

	-- End of the procedure body
	END

-- End of the batch
GO

-- Builds the lookup table for behavior data translation
EXEC dbo.proc_make_behavior_lookup;

