# SQL Schema (pl_21_25)

This project uses a simple star-schema style model to connect match-level team performance across 4 Premier League seasons (21-22 to 24-25).

## Tables

### dim_season
**Grain:** 1 row per season  
**Primary key:** `season_id`

- `season_id` (INT) — surrogate key (1..4)
- `season` (VARCHAR) — season label (e.g., `21-22`)

### dim_team
**Grain:** 1 row per team (across all seasons)  
**Primary key:** `team_id`

- `team_id` (INT) — surrogate key
- `team` (VARCHAR) — team name (standardized)

> Note: `dim_team` contains 26 teams because it is the union of all teams that appeared across the 4 seasons (promotion/relegation).

### dim_match
**Grain:** 1 row per match  
**Primary key:** `match_id`

- `match_id` (VARCHAR) — stable match identifier (see below)
- `season_id` (INT) — FK → `dim_season(season_id)`
- `date` (DATE)
- `home_team_id` (INT) — FK → `dim_team(team_id)`
- `away_team_id` (INT) — FK → `dim_team(team_id)`
- `home_goals` (INT)
- `away_goals` (INT)
- `match_label` (VARCHAR) — readable label (e.g., `Arsenal 2-1 Chelsea`)

### fact_team_match
**Grain:** 1 row per team per match (so 2 rows per match)  
**Primary key (composite):** (`match_id`, `team_id`)  
**Foreign keys:**
- `match_id` → `dim_match(match_id)`
- `team_id` → `dim_team(team_id)`
- `opponent_team_id` → `dim_team(team_id)`
- `season_id` → `dim_season(season_id)`

Contains all original metrics plus derived fields:
- `is_home` (TINYINT)
- `goals_for`, `goals_against` (INT)
- `result` (`W`, `D`, `L`)
- `points` (3/1/0)
- `xT_diff`
- `shot_quality` (= xG / Shots, when Shots > 0)
- `shot_quality_conceded` (= xGA / Shots Faced, when Shots Faced > 0)

## match_id definition

`match_id` is constructed to be stable and unique per league match:

**Format:**
`<Season>|<Date>|<HomeTeam>|<AwayTeam>`

**Example:**
`21-22|2022-05-22|Norwich City|Tottenham Hotspur`

Because each Premier League match occurs once per season for a given home/away pairing, this identifier is stable for this dataset.

## QA checks (expected counts)

- 4 seasons
- 380 matches per season → 1520 matches total
- 760 fact rows per season (2 rows per match) → 3040 total
- Each `match_id` appears exactly 2 times in `fact_team_match`
- No orphan rows: all FKs in `fact_team_match` match existing rows in dimension tables
