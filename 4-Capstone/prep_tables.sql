/* !preview con=DBI::dbConnect(RPostgres::Postgres(),
                      dbname = Sys.getenv("oly_dbname"),
                      host = Sys.getenv("oly_host"),
                      user = Sys.getenv("oly_user"),
                      password = Sys.getenv("oly_password"),
                      port = Sys.getenv("oly_port")))
*/

-- handle missing data for regions
UPDATE noc_regions_raw
  SET region = (CASE WHEN region = 'NA' THEN NULL ELSE region END),
      note = (CASE WHEN note = 'NA' THEN NULL ELSE note END);
      
-- create empty tables
DROP TABLE IF EXISTS regions CASCADE;
CREATE TABLE regions (
  id SERIAL,
  region VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);

DROP TABLE IF EXISTS nocs CASCADE;
CREATE TABLE nocs (
  id SERIAL,
  noc VARCHAR(128) UNIQUE,
  region_id INTEGER,
  PRIMARY KEY(id),
  CONSTRAINT fk_regions
    FOREIGN KEY (region_id)
        REFERENCES regions(id)
);

DROP TABLE IF EXISTS notes CASCADE;
CREATE TABLE notes (
  id SERIAL,
  note VARCHAR(128) UNIQUE,
  noc_id INTEGER,
  PRIMARY KEY(id),
  CONSTRAINT fk_nocs
    FOREIGN KEY (noc_id)
        REFERENCES nocs(id)
);

-- insert data
INSERT INTO regions (region) 
  SELECT DISTINCT region
  FROM noc_regions_raw 
  ORDER BY region;

-- update raw table 
UPDATE noc_regions_raw SET
    region_id = (SELECT regions.id FROM regions 
        WHERE regions.region = noc_regions_raw.region);

INSERT INTO nocs (noc, region_id) 
  SELECT DISTINCT noc, region_id
  FROM noc_regions_raw 
  ORDER BY noc;

UPDATE noc_regions_raw SET 
    noc_id = (SELECT nocs.id FROM nocs 
        WHERE nocs.noc = noc_regions_raw.noc);

INSERT INTO notes (note, noc_id) 
  SELECT DISTINCT note, noc_id
  FROM noc_regions_raw 
  ORDER BY note;

DROP TABLE IF EXISTS noc_regions_raw;

-- handle missing data for athlete events
UPDATE athlete_events_raw SET 
    sex = (CASE WHEN sex = 'NA' THEN NULL
        ELSE sex END),
    age = (CASE WHEN age = 'NA' THEN NULL
        ELSE age END),
    height = (CASE WHEN height = 'NA' THEN NULL
        ELSE height END),
    weight = (CASE WHEN weight = 'NA' THEN NULL
        ELSE weight END),
    team = (CASE WHEN team = 'NA' THEN NULL
        ELSE team END),
    noc = (CASE WHEN noc = 'NA' THEN NULL
        ELSE noc END),
    games = (CASE WHEN games = 'NA' THEN NULL
        ELSE games END),
    season = (CASE WHEN season = 'NA' THEN NULL
        ELSE season END),
    city = (CASE WHEN city = 'NA' THEN NULL
        ELSE city END),
    sport = (CASE WHEN sport = 'NA' THEN NULL
        ELSE sport END),
    event = (CASE WHEN event = 'NA' THEN NULL
        ELSE event END),
    medal = (CASE WHEN medal = 'NA' THEN NULL
        ELSE medal END),
    medal_id = (CASE 
        WHEN medal = 'Gold' THEN 1
        WHEN medal = 'Silver' THEN 2
        WHEN medal = 'Bronze' THEN 3
        END);

-- equestrian events in 1956 summer games held in 2 cities
UPDATE athlete_events_raw SET city =  'Melbourne'
WHERE games = '1956 Summer';

-- create and fill tables without foreign keys
DROP TABLE IF EXISTS teams CASCADE;
CREATE TABLE teams (
  id SERIAL,
  team VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);

INSERT INTO teams (team) 
  SELECT DISTINCT team
  FROM athlete_events_raw 
  ORDER BY team;

DROP TABLE IF EXISTS games CASCADE;
CREATE TABLE games (
  id SERIAL,
  year INTEGER,
  season CHAR(6),
  city VARCHAR(64),
  PRIMARY KEY(id)
);

INSERT INTO games (year, season, city) 
  SELECT DISTINCT year, season, city
  FROM athlete_events_raw 
  ORDER BY year, season;

DROP TABLE IF EXISTS sports CASCADE;
CREATE TABLE sports (
  id SERIAL,
  sport VARCHAR(128) UNIQUE, 
  PRIMARY KEY(id)
);

INSERT INTO sports (sport) 
  SELECT DISTINCT sport
  FROM athlete_events_raw 
  ORDER BY sport;

DROP TABLE IF EXISTS athletes CASCADE;
CREATE TABLE athletes (
  id SERIAL,
  athlete_name VARCHAR(128),
  athlete_sex CHAR(1),
  PRIMARY KEY(id)
);

INSERT INTO athletes (id, athlete_name, athlete_sex) 
  SELECT DISTINCT id, name, sex
  FROM athlete_events_raw 
  ORDER BY id;

DROP TABLE IF EXISTS medals CASCADE;
CREATE TABLE medals (
  id SERIAL,
  medal VARCHAR(6) UNIQUE, 
  PRIMARY KEY(id)
);

INSERT INTO medals (id, medal) 
  SELECT DISTINCT medal_id, medal
  FROM athlete_events_raw
  WHERE medal_id IS NOT NULL
  ORDER BY medal_id;


-- backfill IDs into raw table
UPDATE athlete_events_raw SET 
    noc_id = (SELECT nocs.id FROM nocs
        WHERE nocs.noc = athlete_events_raw.noc),
    team_id = (SELECT teams.id FROM teams 
        WHERE teams.team = athlete_events_raw.team),
    games_id = (SELECT games.id FROM games 
        WHERE games.year = athlete_events_raw.year AND
            games.season = athlete_events_raw.season),
    sport_id = (SELECT sports.id FROM sports 
        WHERE sports.sport = athlete_events_raw.sport),
    athlete_id = (SELECT athletes.id FROM athletes 
        WHERE athletes.id = athlete_events_raw.id),
    medal_id = (SELECT medals.id FROM medals 
        WHERE medals.medal = athlete_events_raw.medal);

-- create tables with foreign keys 
DROP TABLE IF EXISTS events CASCADE;
CREATE TABLE events (
  id SERIAL,
  event VARCHAR(128) UNIQUE,
  sport_id INTEGER,
  PRIMARY KEY(id),
  CONSTRAINT fk_sports
    FOREIGN KEY(sport_id)
      REFERENCES sports(id)
);

INSERT INTO events (event, sport_id) 
  SELECT DISTINCT event, sport_id
  FROM athlete_events_raw 
  ORDER BY event;

-- more cleaning
ALTER TABLE athlete_events_raw
ALTER COLUMN age TYPE INTEGER USING age::INTEGER;
ALTER TABLE athlete_events_raw
ALTER COLUMN height TYPE INTEGER USING height::INTEGER;
ALTER TABLE athlete_events_raw
ALTER COLUMN weight TYPE NUMERIC(4,1) USING weight::NUMERIC;

DROP TABLE IF EXISTS participants CASCADE;
CREATE TABLE participants (
  id SERIAL,
  athlete_id INTEGER,
  games_id INTEGER,
  age INTEGER,
  height INTEGER,
  weight NUMERIC(4,1),
  team_id INTEGER,
  noc_id INTEGER,
  PRIMARY KEY(id),
  CONSTRAINT fk_athletes
    FOREIGN KEY(athlete_id)
        REFERENCES athletes(id),
  CONSTRAINT fk_games
    FOREIGN KEY(games_id)
        REFERENCES games(id),
  CONSTRAINT fk_teams
    FOREIGN KEY(team_id)
        REFERENCES teams(id),
  CONSTRAINT fk_nocs
    FOREIGN KEY(noc_id)
        REFERENCES nocs(id)
);

INSERT INTO participants (athlete_id, games_id, age, height, weight, team_id, noc_id) 
  SELECT DISTINCT athlete_id, games_id, age, height, weight, team_id, noc_id
  FROM athlete_events_raw 
  ORDER BY athlete_id, games_id;

-- backfill IDs again; takes forever 
UPDATE athlete_events_raw SET
    event_id = (SELECT events.id FROM events 
        WHERE events.event = athlete_events_raw.event),
    participant_id = (SELECT participants.id FROM participants
        WHERE participants.athlete_id = athlete_events_raw.athlete_id AND 
            participants.games_id = athlete_events_raw.games_id AND
            participants.team_id = athlete_events_raw.team_id AND
            participants.noc_id = athlete_events_raw.noc_id);

-- one more
DROP TABLE IF EXISTS performances CASCADE;
CREATE TABLE performances (
  id SERIAL,
  participant_id INTEGER,
  event_id INTEGER,
  medal_id INTEGER,
  PRIMARY KEY(id),
  CONSTRAINT fk_participants
    FOREIGN KEY(participant_id)
      REFERENCES participants(id),
  CONSTRAINT fk_events
    FOREIGN KEY(event_id)
      REFERENCES events(id),
  CONSTRAINT fk_medals
    FOREIGN KEY(medal_id)
      REFERENCES medals(id)
);

INSERT INTO performances (participant_id, event_id, medal_id) 
  SELECT DISTINCT participant_id, event_id, medal_id
  FROM athlete_events_raw 
  ORDER BY participant_id, event_id;

DROP TABLE IF EXISTS athlete_events_raw;
