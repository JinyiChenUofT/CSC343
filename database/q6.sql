SET SEARCH_PATH TO parlgov;
drop table if exists q6 cascade;

-- You must not change this table definition.


CREATE TABLE q6(
        countryName VARCHAR(50),
        r0_2 INT,
        r2_4 INT,
        r4_6 INT,
        r6_8 INT,
        r8_10 INT
);

--find left-right position of every party
CREATE OR REPLACE VIEW partyPosition AS
SELECT party.id AS party_id, country_id, left_right
FROM party JOIN party_position ON party.id = party_id
WHERE left_right IS NOT NULL;

--flag them with ranges
CREATE OR REPLACE VIEW partywithrange AS
SELECT party_id, country_id, CASE
		WHEN (left_right >= 0 and left_right < 2)  THEN '02'
		WHEN (left_right >= 2 and left_right < 4)  THEN '24'
		WHEN (left_right >= 4 and left_right < 6)  THEN '46'
		WHEN (left_right >= 6 and left_right < 8)  THEN '68'
		WHEN left_right >= 8 THEN '810'
	END AS position
FROM partyPosition
ORDER BY country_id, position;

--SELECT party_id, country_id, position
--FROM partywithrange;

CREATE OR REPLACE VIEW countryWithCount AS
SELECT country_id,
    sum(CASE WHEN position = '02' then 1 else 0 end ) AS r0_2,
    sum(CASE WHEN position = '24' then 1 else 0 end ) AS r2_4,
    sum(CASE WHEN position = '46' then 1 else 0 end ) AS r4_6,
    sum(CASE WHEN position = '68' then 1 else 0 end ) AS r6_8,
    sum(CASE WHEN position = '810' then 1 else 0 end ) AS r8_10
FROM partywithrange
GROUP BY country_id;

CREATE OR REPLACE VIEW answer AS
SELECT name as countryName, r0_2, r2_4, r4_6, r6_8, r8_10
FROM countryWithCount c1 RIGHT JOIN country c2 on c2.id = c1.country_id;

INSERT INTO q6
SELECT countryName, r0_2, r2_4, r4_6, r6_8, r8_10
FROM answer; 

