/*

  This query assumes you have PostgreSQL 9.5 or later installed and running on your machine.  
  If it is installed, to enable geocoding capabilities you'll need to install/create some extensions:

  CREATE EXTENSION postgis;
  CREATE EXTENSION fuzzystrmatch;
  CREATE EXTENSION postgis_tiger_geocoder;

  You'll also need to install the TDS Foreign Data Wrapper which you can find here:

  https://github.com/tds-fdw/tds_fdw

  Once installed/built you would then create the appropriate extension using 

  CREATE EXTENSION tds_fdw;

  Once the dependencies are installed/built, the script below should be easy to modify and use to geocode 
  student addresses.  This does require creating a table on the IC instance in the database you ID containing 
  the results from the query that was used previously to get the addresses needed for redistricting.

*/


-- Creates a foreign server connected to IC machine using my DB
CREATE SERVER fcps_bb
    FOREIGN DATA WRAPPER tds_fdw
    OPTIONS (servername 'IP Address for Server Goes Here',port '1433', database 'Name of the Database to connect to goes here');

-- Make sure the owner is set to the local owner (change billy to what ever user
-- name you created when you installed PostgreSQL on your machine)
ALTER SERVER fcps_bb
    OWNER TO billy;

-- Maps a PostgreSQL user to a user on the foreign server
-- Enter your user name and password below so it can connect to IC
CREATE USER MAPPING FOR billy SERVER fcps_bb
	OPTIONS ( username 'Your Username Goes Here', password 'Your Password Goes Here');

-- Create the foreign table based on the types returned from the address query
-- developed for last year
CREATE FOREIGN TABLE fcps_addresses (
	studentNumber VARCHAR(15),
	lastName VARCHAR(50),
	firstName VARCHAR(50),
	HomeLanguage VARCHAR(100),
	Homeless VARCHAR(3),
	grade VARCHAR(4),
	enrollmentReason VARCHAR(256),
	enrollmentDescription VARCHAR(100),
	endYear SMALLINT,
	schoolName VARCHAR(50),
	householdID INT,
	HouseholdName VARCHAR(50),
	guaPersonID INT,
	GuardianLast VARCHAR(50),
	GuardianFirst VARCHAR(50),
	livesWith VARCHAR(1),
	number VARCHAR(19),
	prefix VARCHAR(10),
	street VARCHAR(30),
	tag VARCHAR(20),
	direction VARCHAR(10),
	apt VARCHAR(17),
	city VARCHAR(24),
	state VARCHAR(2),
	zip	 VARCHAR(10),
	addy VARCHAR(200)
)

-- The server option lets it know that it is going to be connected to a different server
SERVER fcps_bb

-- Then you can create the table using an argument to select the values.  
-- It tends to work better if the table already exists in the IC instance
OPTIONS (query 'SELECT * FROM dbo.fcps_addresses');

-- Now create a local version of the table on your machine (this should improve performance
-- for the geocoding and address standardization operations).
CREATE TABLE geocoded_addresses AS (
	SELECT *
	FROM fcps_addresses
);

-- Adds a normalized address typed column to the table
ALTER TABLE geocoded_addresses ADD COLUMN clnaddy norm_addy;

-- Adds a geometry column to the table (based on the geometry the corresponding 
-- latitude and longitude values can be queried)
ALTER TABLE geocoded_addresses ADD COLUMN the_geom Geometry;

-- Adds a column to store latitudes
ALTER TABLE geocoded_addresses ADD COLUMN lat DOUBLE PRECISION;

-- Adds a column to store longitudes
ALTER TABLE geocoded_addresses ADD COLUMN lon DOUBLE PRECISION;

-- Adds a column to store the geocoding quality
ALTER TABLE geocoded_addresses ADD COLUMN rating INT;

-- Creates an ID column used to iterate over records and geocode them
ALTER TABLE geocoded_addresses ADD COLUMN id SERIAL;

-- Creates a boolean indicating whether or not the address is within highschool attendance zones
ALTER TABLE geocoded_addresses ADD COLUMN infcps BOOLEAN;

-- Creates an index on the ID column where NULL values in the ratings column appear first
CREATE INDEX idx_geocoded_addresses ON geocoded_addresses(id, rating NULLS FIRST);

-- This query updates the table with a single complete address for each record
-- * SQL Server was being a pain about handling null values and empty strings so this was just a way to 
-- get things turned around a bit faster
UPDATE geocoded_addresses
SET addy = (a.addy)
FROM (SELECT id, number || ' ' || prefix || ' ' || street || ' ' || tag || ', ' || city || ', ' || state || ', ' || zip AS addy 
      FROM geocoded_addresses 
      WHERE addy IS NULL OR addy IN ('', '   , , , ')) AS a
WHERE a.id = geocoded_addresses.id;      

-- This query sets the values for the normalized address column (clnaddy).  This prevents the 
-- geocode function from needing to first normalize the address prior to geocoding and is solely 
-- to get a bit of a performance gain.  The normalized address column could also be created from the 
-- result set of the geocode function.
UPDATE geocoded_addresses
 SET  (clnaddy) = (a.clnaddy)
 	FROM (SELECT id, normalize_address(addy) AS clnaddy
   FROM geocoded_addresses
   WHERE clnaddy IS NULL) AS a 
   WHERE a.id = geocoded_addresses.id;

-- This is the start of an anonymous code block (e.g., annonymous function) used to run loops and the sort
DO $$

	-- Starts the body of the annonymous function
    BEGIN

		-- In subsequent years the 41,552 value would need to be checked but this is a way of iterating 
        -- over each record of the table.
        FOR needsgeocoding IN 1..41552 LOOP
        
        	-- Update the table and set the values of the rating, the_geom, lon, and lat columns
            -- The COALESCE function is analogous to the NULLIF function in SQL Server (e.g., if the 
            -- value is null it will use -1 as the default value).  In PostgreSQL you can use type 
            -- casting via :: followed by the name of the type.  
            UPDATE geocoded_addresses
            SET  (rating, the_geom, lon, lat) =
                 (COALESCE((g).rating, -1), g.geomout,
                  ST_X((g).geomout)::NUMERIC(38, 34), 
                  ST_Y((g).geomout)::NUMERIC(38, 34) )
            FROM (	
                	-- Selects a single record from the table based on the value of the ID and the 
                	-- variable needsgeocoding created by the loop above
                	SELECT *
               		FROM geocoded_addresses
               		WHERE rating IS NULL AND id = needsgeocoding ) AS a
            -- The LATERAL keyword below doesn't really have an SQL Server equivalent that I'm aware of, 
            -- but allows references to the previous subquery without having to jump through a bunch of 
            -- other hoops to keep the different subqueries related
            LEFT JOIN LATERAL geocode(a.clnaddy, 1) AS g ON ((g).rating < 250)
            
            -- Make sure the ID from the subquery and original table are the same and that 
            -- it is still using the correct ID for this iteration
            WHERE a.id = geocoded_addresses.id AND a.id = needsgeocoding;
            
        -- Move to the next iteration or finish the loop    
        END LOOP;

-- End of the anonymous function
END$$;

-- Adds indicator for whether or not the address is within FCPS boundaries
UPDATE geocoded_addresses
SET infcps = (a.infcps)
FROM (SELECT geocoded_addresses.id, ST_Contains(high_areas.geom, geocoded_addresses.the_geom) AS infcps
      FROM public.high_areas, tiger.geocoded_addresses) AS a
WHERE a.id = geocoded_addresses.id; 

-- Write the table to disk as a CSV file.
COPY (SELECT * FROM geocoded_addresses) TO '/File/Path/Where you want the/File Saved/geocoded_addresses.csv' WITH CSV;