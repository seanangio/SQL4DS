-- create raw table with FK cols
DROP TABLE IF EXISTS noc_regions_raw;
CREATE TABLE noc_regions_raw (
    noc CHAR(3),
    noc_id INTEGER,
    region VARCHAR(128),
    region_id INTEGER,
    note VARCHAR(128)
);

DROP TABLE IF EXISTS athlete_events_raw;
CREATE TABLE athlete_events_raw (
    id INTEGER, 
    name VARCHAR(128), athlete_id INTEGER,
    sex CHAR(1),
    age VARCHAR(2),
    participant_id INTEGER,
    height VARCHAR(3),
    weight TEXT,
    team VARCHAR(64), team_id INTEGER,
    noc CHAR(3), noc_id INTEGER,
    games CHAR(11),
    year INTEGER, games_id INTEGER,
    season CHAR(6),
    city VARCHAR(64),
    sport VARCHAR(64), sport_id INTEGER, 
    event VARCHAR(128), event_id INTEGER,
    medal VARCHAR(6), medal_id INTEGER
);
