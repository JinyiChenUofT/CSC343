SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

create table q3(
 countryName VARCHaR(100),
 partyName VARCHaR(100),
 partyFamily VARCHaR(100),
 wonElections INT,
 mostRecentlyWonElectionId INT,
 mostRecentlyWonElectionYear INT
);

--all winnings of all parties ,including the # votes, date of election
CREATE or REPLACE VIEW winner_party AS
SELECT t.election_id, election_result.party_id, votes
FROM 
	(SELECT election_id, MAX(votes) AS maxV
	FROM election_result
	GROUP BY election_id
	)t JOIN election_result on t.election_id = election_result.election_id AND t.maxV = election_result.votes
;

--number of wins of each party
CREATE or REPLACE VIEW num_wins AS
SELECT party_id, country_id, COUNT(*) AS winCount
FROM winner_party, party
WHERE winner_party.party_id = party.id
GROUP BY country_id, party_id
ORDER BY country_id, party_id;

--counts number of parties there are in each country
CREATE OR REPLACE VIEW numParties AS
SELECT country_id, COUNT(id) AS parties
FROM party
GROUP BY country_id
ORDER BY country_id;

--counts how many wins there are in each country
CREATE OR REPLACE VIEW total_wins AS
SELECT country_id, SUM(wincount) AS totalWins
FROM num_wins
GROUP BY country_id
ORDER BY country_id;

--average wins of parties in the same country 
CREATE or REPLACE VIEW average_win AS
SELECT w.country_id, totalWins/parties AS avg_win
FROM total_wins w JOIN numParties p on w.country_id = p.country_id;

--parties that won 3 times more than the average
CREATE or REPLACE VIEW super_party AS
SELECT party_id, n.country_id, avg_win, winCount
FROM num_wins n, average_win a
WHERE n.country_id = a.country_id AND n.winCount >= (3*a.avg_win); 

--super parties' most recent winning date
CREATE or REPLACE VIEW most_recent_win AS
SELECT w.party_id, MAX(e_date) AS mostRecentlyWonElectionYear 
FROM winner_party w, super_party s, election e  
WHERE w.party_id = s.party_id and w.election_id = e.id
GROUP BY w.party_id;

--all parties' election ID and date
CREATE OR REPLACE VIEW party_election_id_date AS
SELECT party_id, e_date, election_id
FROM election_result JOIN election on election_result.election_id = election.id;

--super parties' most recent election ID
CREATE OR REPLACE VIEW ans_with_most_recent AS
SELECT s.party_id, mostRecentlyWonElectionYear, election_id 
FROM most_recent_win s JOIN party_election_id_date d on d.party_id = s.party_id AND d.e_date = s.mostRecentlyWonElectionYear;

CREATE OR REPLACE VIEW ans AS
SELECT p.name AS partyName, mostRecentlyWonElectionYear, election_id AS mostRecentlyWonElectionId, family AS party_family, c.name as countryName , winCount as wonElections
FROM ans_with_most_recent a LEFT JOIN party_family f ON f.party_id = a.party_id JOIN party p on p.id = a.party_id JOIN country c on c.id = p.country_id JOIN super_party s on s.party_id = a.party_id;
-- party_family f, party p, super_party s
--WHERE f.party_id = a.party_id and a.party_id = p.id and a.party_id = s.party_id;

INSERT INTO q3
SELECT countryName, partyName, party_family, wonElections, mostRecentlyWonElectionId, EXTRACT(YEAR FROM mostRecentlyWonElectionYear)
FROM ans;
