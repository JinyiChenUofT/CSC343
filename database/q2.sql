SET search_path TO parlgov;
DROP TABLE IF EXISTS q2 CASCADE;

---create table
CREATE TABLE q2(
    countryName VARCHAR(50) NOT NULL,
    partyName VARCHAR(100) NOT NULL,
    partyFamily  VARCHAR(50),
    stateMarket  REAL  
);

--drop view if exists
DROP VIEW IF EXISTS  CASCADE;
DROP VIEW IF EXISTS  CASCADE;

--cabinet over the past 20 years
CREATE VIEW past20Cabinet AS
SELECT id as cabinet_id, country_id
FROM cabinet
WHERE EXTRACT(YEAR FROM c.start_date)>=1999 and EXTRACT(YEAR FROM c.start_date)<2019;

--count of cabient
CREATE VIEW cabientsEachCountry AS
SELECT country_id, count(*) as cabient_nums
FROM past20Cabinet
GROUP BY country_id;

SELECT c.id as cabinet_id, party_id  
FROM cabinet_party c
WHERE ALL(cabinet_id) IN
(SELECT cabinet_id FROM past20Cabinet p) and c.party_id = p.party_id;

CREATE TABLE country(
  id INT primary key,
  -- The full name of the country.
  name VARCHAR(50) NOT NULL UNIQUE,
  -- An abbreviation of the country's name, following the ISO alpha-3
  -- standard.  Reference: https://www.iso.org/iso-3166-country-codes.html
  abbreviation VARCHAR(10) UNIQUE,
  -- The date on which the country joined the OECD.
  oecd_accession_date DATE NOT NULL
);



-- A party that was part of parliament during the period of a cabinet.
CREATE TABLE cabinet_party(
  id INT PRIMARY KEY,
  cabinet_id INT REFERENCES cabinet(id),
  party_id INT REFERENCES party(id),
  -- True iff this party fills the position of prime minister.
  pm BOOLEAN NOT NULL,
  -- Further information about this relationship between a party and cabinet.
  description VARCHAR(1000)
);


-- A political party, such as the New Democratic Party of Canada.
CREATE TABLE party(
  id INT PRIMARY KEY,
  -- The country in which this political party operates.
  country_id INT REFERENCES country(id),
  -- An abbreviation for the name of this party.
  name_short VARCHAR(10) NOT NULL,
  -- The full name of this party.
  name VARCHAR(100) NOT NULL, 
  -- Further information about this party.
  description VARCHAR(1000),
  UNIQUE(country_id, name_short)
);

CREATE TABLE cabinet(
  id INT PRIMARY KEY,
  -- The country in which this cabinet occurred.
  country_id INT REFERENCES country(id),
  -- The date on which this cabinet came into being.
  start_date DATE NOT NULL,
  -- A label for this cabinet, consisting of the family name of the
  -- prime minister and a roman numeral if he/she headed more than one
  -- cabinet.
  name VARCHAR(50) NOT NULL UNIQUE,
  -- A wikepedia entry or other webpage about this cabinet.
  wikipedia VARCHAR(500),
  -- Further information about this cabinet.
  description VARCHAR(1000),
  -- Further information about this cabinet.
  comment VARCHAR(1000),
  -- The previous cabinet for this country.  This attribute forms a 
  -- "linked list" of cabinets for each country.
  -- Constraint: The country_id for this cabinet and the previous cabinet
  -- must be the same.
  previous_cabinet_id INT REFERENCES cabinet(id),
  -- The ID of the parliamentary election associated this cabinet.
  election_id INT 
);



CREATE VIEW  AS
SELECT 
FROM 
GROUP BY 



INSERT into q1(countryId,alliedPartyId1,alliedPartyId2)
SELECT * 
FROM results;



