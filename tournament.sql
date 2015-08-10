--connecting and removing old database 

\c vagrant

DROP DATABASE if exists tournament;


--recreating a new database

CREATE DATABASE tournament;

\c tournament

-- table and view creation for database

CREATE TABLE Players(
	P_id serial PRIMARY KEY,
	player_name varchar(75)
	);

CREATE TABLE Matches(
	M_id serial PRIMARY KEY,
	p1 integer REFERENCES Players(P_id),
        p2 integer REFERENCES Players(P_id),
        p1_res integer,
        p2_res integer
	);

-- Shows match count by player

CREATE VIEW matches_by_player AS
    SELECT
        M_id,
        p1 as player,
        p2 as opponent,
        p1_res as points
    FROM
        Matches
    UNION
    SELECT
        M_id,
        p2 as player,
        p1 as opponent,
        p2_res as points
    FROM
        Matches
    ORDER BY
        M_id;

CREATE VIEW PlayerPoint as
    SELECT
        P_id as id,
        player_name as name,
        sum(points) as points,
        count(points) as matches
    FROM Players
    LEFT JOIN matches_by_player
    ON P_id = player
    GROUP BY P_id
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
 
