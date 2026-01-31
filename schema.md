# SQL Schema (pl_21_25)

This project uses a simple star-schema model to analyse match-level team performance across **4 Premier League seasons (21-22 to 24-25)**.

---

## Tables overview

### `dim_season`
**Grain:** 1 row per season  
**Primary key:** `season_id`

| Column | Type | Description |
|---|---|---|
| `season_id` | INT | Surrogate key (1..4) |
| `season` | VARCHAR(10) | Season label (e.g., `21-22`) |

---

### `dim_team`
**Grain:** 1 row per team (union across all seasons)  
**Primary key:** `team_id`

| Column | Type | Description |
|---|---|---|
| `team_id` | INT | Surrogate key |
| `team_name` | VARCHAR(80) | Standardized team name |

**Note:** `dim_team` contains **26 teams** because it is the union of all teams that appeared across the 4 seasons (promotion/relegation).

---

### `dim_match`
**Grain:** 1 row per match  
**Primary key:** `match_id`

| Column | Type | Description |
|---|---|---|
| `match_id` | VARCHAR(120) | Stable match identifier (see definition below) |
| `season_id` | INT | FK → `dim_season(season_id)` |
| `match_date` | DATE | Match date |
| `home_team_id` | INT | FK → `dim_team(team_id)` |
| `away_team_id` | INT | FK → `dim_team(team_id)` |
| `home_goals` | INT | Goals scored by home team |
| `away_goals` | INT | Goals scored by away team |
| `match_label` | VARCHAR(200) | Readable label (e.g., `Arsenal 2-1 Chelsea`) |

---

### `fact_team_match`
**Grain:** 1 row per **team per match** (therefore **2 rows per match**)  
**Primary key (composite):** (`match_id`, `team_id`)

**Foreign keys:**
- `match_id` → `dim_match(match_id)`
- `season_id` → `dim_season(season_id)`
- `team_id` → `dim_team(team_id)`
- `opponent_team_id` → `dim_team(team_id)`

**Core columns (team perspective):**

| Column | Type | Description |
|---|---|---|
| `match_id` | VARCHAR(120) | Match identifier |
| `season_id` | INT | Season FK |
| `team_id` | INT | Team FK |
| `opponent_team_id` | INT | Opponent team FK |
| `is_home` | TINYINT | 1 = home team, 0 = away team |
| `goals_for` | INT | Goals scored by the team |
| `goals_against` | INT | Goals conceded by the team |
| `result` | CHAR(1) | `W`, `D`, `L` |
| `points` | INT | 3 / 1 / 0 |

**Derived fields added during processing:**
- `xT_diff` = `xT - xT Against`
- `shot_quality` = `xG / Shots` when `Shots > 0`, else NULL
- `shot_quality_conceded` = `xGA / Shots Faced` when `Shots Faced > 0`, else NULL

**Metrics note:** the fact table also includes the original match/team metrics from the source dataset (e.g., xG/xGA/xT and related fields). Some source columns may contain spaces or special characters; for BI tools (e.g., Tableau), it is recommended to expose **snake_case aliases via SQL views**.

---

## `match_id` definition

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

