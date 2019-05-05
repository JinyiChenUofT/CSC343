SET search_path TO parlgov;
DROP TABLE IF EXISTS q5 CASCADE;

---create table
CREATE TABLE q5(
    countryName VARCHAR(50),
    year INT,
    participationRatio REAL
);

DROP VIEW IF EXISTS FifteenYearVotes CASCADE;
DROP VIEW IF EXISTS monoVotes CASCADE;
DROP VIEW IF EXISTS resutls CASCADE;

--select votes for the party, all votes between 1996 - 2016
CREATE VIEW FifteenYearVotes AS
SELECT country_id,  avg(votes_cast::float/electorate::float) as ratio, EXTRACT(YEAR FROM e_date) as year
FROM election
WHERE EXTRACT(YEAR FROM e_date) <= 2016 and EXTRACT(YEAR FROM e_date)>=2001
        and electorate is not null and votes_cast is not null
GROUP BY (country_id,EXTRACT(YEAR FROM e_date)) ;


--select votes for the party, all votes between 1996 - 2016
CREATE VIEW monoVotes AS
SELECT *
FROM FifteenYearVotes
WHERE NOT EXISTS(select * from  FifteenYearVotes f1, FifteenYearVotes f2
              where f1.country_id = f2.country_id and f1.year < f2.year and f1.ratio > f2.ratio);

CREATE VIEW results AS
SELECT c.name as countryName, m.year, m.ratio
FROM monoVotes m, country c;

insert into q5 (year, countryName, participationRatio)
SELECT results.year, results.countryName, results.ratio
FROM results;