SET search_path TO parlgov;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1(
    countryId INT,
    alliedPartyId1 INT,
    alliedPartyId2 INT  
);

DROP VIEW IF EXISTS country_alliances CASCADE;
DROP VIEW IF EXISTS country_election CASCADE;
DROP VIEW IF EXISTS results CASCADE;

--a country's all allied parites
CREATE VIEW country_alliances AS
SELECT e.id, e.country_id, e1.party_id as party1, e2.party_id as party2
FROM election_result e1, election_result e2, election e
WHERE e1.election_id = e2.election_id and e1.election_id = e.id
AND e1.party_id < e2.party_id
AND (e1.alliance_id = e2.id or e1.alliance_id = e2.alliance_id or e1.id = e2.alliance_id)
GROUP BY (e.id, e.country_id, e1.party_id, e2.party_id);


--how many elecitons each country
CREATE VIEW country_election AS 
SELECT country_id, count(*) AS election_num
FROM election
GROUP BY country_id;


--the pair of parties that have been allies with each other in at least 30% of elections 
--that have happened in a country.
CREATE VIEW results AS
SELECT c1.country_id, party1, party2
FROM country_alliances c1, country_election c2
WHERE c1.country_id = c2.country_id
GROUP BY (c1.country_id, c1.party1, c1.party2, c2.election_num)
HAVING COUNT(*) >= 0.3*c2.election_num;

INSERT into q1(countryId,alliedPartyId1,alliedPartyId2)
SELECT country_id, party1, party2
FROM results;
