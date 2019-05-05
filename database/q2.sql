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
DROP VIEW IF EXISTS past20Cabinet CASCADE;
DROP VIEW IF EXISTS cabientsEachCountry CASCADE;
DROP VIEW IF EXISTS cabientsEachParty CASCADE;
DROP VIEW IF EXISTS cabientsEachPartyAndCountry CASCADE;
DROP VIEW IF EXISTS commitedParties_partyId_countryId CASCADE;
DROP VIEW IF EXISTS committedParties_countryName CASCADE;
DROP VIEW IF EXISTS addFaimly CASCADE;
DROP VIEW IF EXISTS results CASCADE;

--cabinet over the past 20 years
CREATE VIEW past20Cabinet AS
SELECT id as cabinet_id, country_id
FROM cabinet
WHERE EXTRACT(YEAR FROM start_date)>=1999 and EXTRACT(YEAR FROM start_date)<2019;

--count of cabient each country
CREATE VIEW cabientsEachCountry AS
SELECT country_id, count(*) as cabient_nums
FROM past20Cabinet
GROUP BY country_id;

--count of cabient each party
CREATE VIEW cabientsEachParty AS
SELECT party_id, count(*) as cabient_nums
FROM cabinet_party
GROUP BY party_id;

--count of cabient each party and their country id
CREATE VIEW cabientsEachPartyAndCountry AS
SELECT party_id, cabient_nums, country_id
FROM cabientsEachParty, party
WHERE party_id = id;

--find committed parties
--A committed party is the one that has been a member of all cabinets in their country
-- over the past 20 years.
CREATE VIEW commitedParties_partyId_countryId AS
SELECT party_id, cp.country_id  
FROM cabientsEachPartyAndCountry cp, cabientsEachCountry cc
WHERE cp.cabient_nums = cc.cabient_nums;

--committedParties with country name
CREATE VIEW committedParties_countryName AS
SELECT c.name as countryName, party_id
FROM commitedParties_partyId_countryId cp, country c
WHERE cp.country_id= c.id;

CREATE VIEW addFaimly AS
SELECT c.*, p.family as partyFamily
FROM committedParties_countryName c
LEFT JOIN party_family p
ON c.party_id = p.party_id;

CREATE VIEW results AS
SELECT a.*, p.state_market as stateMarket 
FROM addFaimly a
LEFT JOIN party_position p
ON a.party_id = p.party_id;

INSERT INTO q2 (countryName,partyName,partyFamily,stateMarket)
SELECT results.countryName, party.name, results.partyFamily, results.stateMarket 
FROM results, party
WHERE results.party_id = party.id;