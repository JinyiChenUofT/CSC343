SET search_path TO parlgov;
DROP TABLE IF EXISTS q4 CASCADE;

---create table
CREATE TABLE q4(
    year INT,
    countryName VARCHAR(50),
    voteRange VARCHAR(20),
    partyName  VARCHAR(100)
);

DROP VIEW IF EXISTS TwentyYearVotes CASCADE; 
DROP VIEW IF EXISTS rangeVotes CASCADE; 
DROP VIEW IF EXISTS rangeVotesWithName CASCADE; 

--select votes for the party, all votes between 1996 - 2016
CREATE VIEW TwentyYearVotes AS
SELECT election.country_id, election_result.party_id, votes as party_votes, 
        votes_valid as all_votes, EXTRACT(YEAR FROM e_date) as e_year
FROM election, election_result
WHERE election.id = election_result.election_id  
        and EXTRACT(YEAR FROM e_date) <= 2016 and EXTRACT(YEAR FROM e_date)>=1996
        and votes is not null and votes_valid is not null;

--group by (election.country_id, election_result.party_id, EXTRACT(YEAR FROM e_date));

CREATE VIEW rangeVotes AS
SELECT e_year,country_id, party_id, avg(party_votes::float/all_votes::float) as ratio
FROM TwentyYearVotes
GROUP BY (e_year,country_id,party_id); 

CREATE VIEW rangeVotesWithName AS
SELECT r.e_year, c.name as countryName, r.ratio, p.name_short as partyName 
FROM rangeVotes r, country c, party p
WHERE c.id = r.country_id and p.id = r.party_id;

-- insert by range 
insert into q4 (year, countryName, voteRange, partyName)
SELECT e_year, countryName, '(0-5]' as ratio, partyName
FROM rangeVotesWithName
WHERE ratio > 0 and ratio <= 0.05;

insert into q4 (year, countryName, voteRange, partyName)
SELECT e_year, countryName, '(5-10]' as ratio, partyName
FROM rangeVotesWithName
WHERE ratio > 0.05 and ratio <= 0.10;

insert into q4 (year, countryName, voteRange, partyName)
SELECT e_year, countryName, '(10-20]' as ratio, partyName
FROM rangeVotesWithName
WHERE ratio > 0.10 and ratio <= 0.20;

insert into q4 (year, countryName, voteRange, partyName)
SELECT e_year, countryName, '(20-30]' as ratio, partyName
FROM rangeVotesWithName
WHERE ratio > 0.20 and ratio <= 0.30;

insert into q4 (year, countryName, voteRange, partyName)
SELECT e_year, countryName, '(30-40]' as ratio, partyName
FROM rangeVotesWithName
WHERE ratio > 0.30 and ratio <= 0.40;

insert into q4 (year, countryName, voteRange, partyName)
SELECT e_year, countryName, '(40-100]' as ratio, partyName
FROM rangeVotesWithName
WHERE ratio > 0.40;