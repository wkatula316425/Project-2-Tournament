--connecting and removing old database 

\c vagrant

DROP DATABASE if exists tournament;


--recreating a new database

CREATE DATABASE tournament;

\c tournament

-- table and view creation for database
-- removed P_id as primary key per first submission
-- naming convention of table in lowercase in both players table and matches table

CREATE TABLE players(
	id serial PRIMARY KEY,   
        player_name varchar(75)
	);

-- changed column names to be more descriptive in table

CREATE TABLE matches(
	M_id serial PRIMARY KEY,
	winner integer REFERENCES Players(id),
        loser integer REFERENCES Players(id),
        winner_score integer,
        loser_score integer
	);

-- Shows match count by player

CREATE VIEW matches_by_player AS
    SELECT
        M_id,
        winner as player,
        loser as opponent,
        winner_score as points
    FROM
        matches
    UNION
    SELECT
        M_id,
        loser as player,
        winner as opponent,
        loser_score as points
    FROM
        matches
    ORDER BY
        M_id;

CREATE VIEW PlayerPoint as
    SELECT
        id as id,
        player_name as name,
        sum(points) as points,
        count(points) as matches
    FROM Players
    LEFT JOIN matches_by_player
    ON id = player
    GROUP BY id
    ORDER BY id;

-- Player points and opponent match points
 
CREATE VIEW CumPoints AS
    SELECT
        player as id,
        COALESCE(SUM(points), 0) as points,
        COALESCE(sum(opp_points), 0) as OMP
    FROM matches_by_player as POMP1
    LEFT JOIN
        (SELECT
             POMP2.player as opponent,
             COALESCE(SUM(points), 0) as opp_points
         FROM matches_by_player as POMP2
         WHERE player IN
             (SELECT opponent
              FROM matches_by_player as POMP3)
         GROUP BY POMP2.player) as opp_list
         ON POMP1.opponent = opp_list.opponent
    GROUP BY player
    ORDER BY player;
