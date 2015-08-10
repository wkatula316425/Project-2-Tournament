#!/usr/bin/env python
# 
# tournament.py -- implementation of a Swiss-system tournament
#

import psycopg2

def connect():
    """Connect to the PostgreSQL database.  Returns a database connection."""
    return psycopg2.connect("dbname=tournament")


def deleteMatches():
    """Remove all the match records from the database."""
    db = connect()
    c= db.cursor()
    c.execute("DELETE FROM Matches") # tried truncate table error messages saying that references already existed
    db.commit()
    db.close()

def deletePlayers():
    """Remove all the player records from the database."""
    db = connect()
    c= db.cursor()
    c.execute("DELETE FROM Players") # tried truncate table but kept getting error mesages
    db.commit()
    db.close()

def countPlayers():
    """Returns the number of players currently registered."""
    db = connect()
    c= db.cursor()
    c.execute("SELECT count(*) FROM Players;")
    count = c.fetchone()
    db.close()
    return count[0]
    


def registerPlayer(name):
    """Adds a player to the tournament database.
  
    The database assigns a unique serial id number for the player.  (This
    should be handled by your SQL database schema, not in your Python code.)
  
    Args:
      name: the player's full name (need not be unique).
    """
    db = connect()
    c = db.cursor()
    c.execute("INSERT INTO Players(player_name) VALUES (%s)", (name,))
    db.commit()
    db.close();


def playerStandings():
    """Returns a list of the players and their win records, sorted by wins.

    The first entry in the list should be the player in first place, or a player
    tied for first place if there is currently a tie.

    Returns:
      A list of tuples, each of which contains (id, name, wins, matches):
        id: the player's unique id (assigned by the database)
        name: the player's full name (as registered)
        wins: the number of matches the player has won
        matches: the number of matches the player has played
    """
    db = connect()
    c= db.cursor()
    c.execute("""SELECT
                    id,
                    name,
                    COALESCE(points,0) as points,
                    COALESCE(matches,0) as matches
                FROM(
                    SELECT
                        p.id,
                        p.name,
                        p.points,
                        p.matches,
                        o.OMP
                    FROM PlayerPoint p
                    LEFT JOIN CumPoints o
                    ON p.id = o.id
                    ORDER BY p.points desc, o.OMP desc) OMP""")
    rows = c.fetchall()
    db.close();
    return rows


def reportMatch(winner, loser):
    """Records the outcome of a single match between two players.

    Args:
      winner:  the id number of the player who won
      loser:  the id number of the player who lost
      p1_res and p2 result default and are not passed into function as args but predetermined point values
    """
    db = connect()
    c = db.cursor()
    c.execute("INSERT INTO Matches (p1, p2, p1_res, p2_res) VALUES (%s,%s,1,0)", (winner, loser))
    db.commit()
    db.close()
 
 
def swissPairings():
    """Returns a list of pairs of players for the next round of a match.
  
    Assuming that there are an even number of players registered, each player
    appears exactly once in the pairings.  Each player is paired with another
    player with an equal or nearly-equal win record, that is, a player adjacent
    to him or her in the standings.
  
    Returns:
      A list of tuples, each of which contains (id1, name1, id2, name2)
        id1: the first player's unique id
        name1: the first player's name
        id2: the second player's unique id
        name2: the second player's name
    """
    

    #Retrieve Standings
    standings = playerStandings()
    pairings = []

       
    #form pairings and returns tuples
        
    return [(p1[0], p1[1], p2[0], p2[1]) for p1, p2 in zip(standings[::2], standings[1::2])]
            
