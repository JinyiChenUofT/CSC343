SET search-path TO parlgov;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1(
    countryId INT,
    alliedPartyId1 INT,
    alliedPartyId2 INT  
);