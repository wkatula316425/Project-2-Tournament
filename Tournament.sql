-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.
--
-- Clearing old data from DB
--
-- Drop old tables and views

DROP VIEW IF EXISTS Standings;
DROP VIEW IF EXISTS Count;
DROP VIEW IF EXISTS Wins;
DROP TABLE IF EXISTS Matches;
DROP TABLE IF EXISTS Players;


def Create_database_tables():

CREATE TABLE Players(
	player_id serial primary key,
	name varchar(255)
	);

CREATE TABLE Matches(
	id serial primary key,
	player int references Players(id),
        opponent int references Players(id),
        result int
	);

-- Shows number of wins

CREATE VIEW Wins AS
        SELECT Players.id, COUNT(Matches.opponent) AS n
        FROM Players
        LEFT JOIN (SELECT * FROM Matches WHERE results > 0) AS Matches
        ON Players.id = Matches.player
        GROUP BY Players.id;

-- Shows match count

CREATE VIEW Count AS
    SELECT Players.id, Count(Matches.opponent) AS n
    FROM Players
    LEFT JOIN Matches
    ON Players.id = Matches.player
    GROUP BY Players.id;

-- Shows Standings showing number of wins
 
CREATE VIEW Standings AS
    SELECT Players.id, Players.name, Wins.n as wins, Count.n as matches
    FROM Players, Count, Wins
    WHERE Players.id = Wins.id and Wins.id = Count.id;


