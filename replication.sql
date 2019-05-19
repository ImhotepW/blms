-- Replication process in a parallel scheme

CREATE MATERIALIZED VIEW BUDGET_R 
REFRESH ON COMMIT 
FAST AS 
SELECT *
  FROM BLMS.BUDGET;

CREATE MATERIALIZED VIEW CLUB_R 
REFRESH ON COMMIT 
FAST AS 
SELECT *
  FROM BLMS.CLUB;

CREATE MATERIALIZED VIEW CONTRACT_R 
REFRESH ON COMMIT 
FAST AS 
SELECT *
  FROM BLMS.CONTRACT;

CREATE MATERIALIZED VIEW LEAGUE_R 
REFRESH ON COMMIT 
FAST AS 
SELECT *
  FROM BLMS.LEAGUE;

CREATE MATERIALIZED VIEW LEAGUE_SEASON_CLUB_REL_R 
REFRESH ON COMMIT 
FAST AS 
SELECT *
  FROM BLMS.LEAGUE_SEASON_CLUB_REL;

CREATE MATERIALIZED VIEW LUXURY_TAX_R 
REFRESH ON COMMIT 
FAST AS 
SELECT *
  FROM BLMS.LUXURY_TAX;

CREATE MATERIALIZED PLAYER_R 
REFRESH ON COMMIT 
FAST AS 
SELECT *
  FROM BLMS.PLAYER;

CREATE MATERIALIZED VIEW PLAYER_POSITION_REL_R 
REFRESH ON COMMIT 
FAST AS 
SELECT *
  FROM BLMS.PLAYER_POSITION_REL;
  
CREATE MATERIALIZED VIEW POSITION_R 
REFRESH ON COMMIT 
FAST AS 
SELECT *
  FROM BLMS.POSITION;

CREATE MATERIALIZED VIEW SEASON_R 
REFRESH ON COMMIT 
FAST AS 
SELECT *
  FROM BLMS.SEASON;

CREATE MATERIALIZED VIEW TRADE_R 
REFRESH ON COMMIT 
FAST AS 
SELECT *
  FROM BLMS.TRADE;