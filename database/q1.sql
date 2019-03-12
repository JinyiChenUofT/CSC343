SET search_path TO parlgov;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1(
    countryId INT,
    alliedPartyId1 INT,
    alliedPartyId2 INT  
);

DROP VIEW IF EXISTS election_party CASCADE;
DROP VIEW IF EXISTS country_alliances CASCADE;
DROP VIEW IF EXISTS count_election_party CASCADE;
DROP VIEW IF EXISTS country_election CASCADE;
DROP VIEW IF EXISTS results CASCADE;

--allied parties

--a country's all allied parites
CREATE VIEW election_party AS
SELECT e.id, election_id, party_id, alliance_id, country_id
FROM party p, election_result e
WHERE p.id = e.party_id;

CREATE VIEW country_alliances AS
SELECT e2.country_id as countryId, e2.party_id as alliedPartyId1, e1.party_id as alliedPartyId2
FROM election_party e1, election_party e2
WHERE e1.election_id = e2.election_id and e1.country_id = e2.country_id and e2.party_id < e1.party_id and (e1.alliance_id = e2.id or e1.alliance_id = e2.alliance_id);

CREATE VIEW count_election_party AS
SELECT countryId,alliedPartyId1,alliedPartyId2,count(*) as election_num
FROM country_alliances
GROUP BY (countryId,alliedPartyId1,alliedPartyId2);

CREATE VIEW country_election AS
SELECT country_id, count(*) as election_num
FROM election
GROUP BY country_id;

CREATE VIEW results AS
SELECT c1.countryId, c1.alliedPartyId1, c1.alliedPartyId2, 
FROM count_election_party c1, country_election c2
WHERE c1.countryId = c2.country_id and c1.election_num > 0.3*c2.election_num;


INSERT into q1(countryId,alliedPartyId1,alliedPartyId2)
SELECT * 
FROM results;



