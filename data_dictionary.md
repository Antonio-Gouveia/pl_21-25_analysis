# Data Dictionary (v1) — Premier League Team × Match (2021–2025)

## Overview
- **Source:** Opta (team match metrics)
- **Granularity:** *Team × Match* (760 rows per season)
- **Seasons:** 2021–22, 2022–23, 2023–24, 2024–25
- **Key fields:** `Team`, `Season`, `Date`, `Match`

> **Note:** Some provider definitions (e.g., *Field Tilt*, *Game Control*, *Pressure*) can vary slightly by methodology. In this project, they are interpreted as standardized proxies for territory/control and pressing behavior.

---

## Columns

| Column | Type | Meaning |
|---|---|---|
| Team | text | Team name (normalized across seasons) |
| Season | text | Season label (e.g., `Premier League Full Match List 21-22`) |
| Date | date/text | Match date (to be standardized to `YYYY-MM-DD`) |
| Match | text | Match string (e.g., `Home Team 1-2 Away Team`) |
| xG | float | Expected goals **for** the team in the match |
| xGA | float | Expected goals **against** the team in the match |
| xGD | float | Expected goal difference: `xG - xGA` |
| Open Play xG | float | xG created from open play |
| Open Play xGA | float | xG conceded from open play |
| Open Play xGD | float | Open play xG difference: `Open Play xG - Open Play xGA` |
| Set Piece xG | float | xG created from set pieces |
| Set Piece xGA | float | xG conceded from set pieces |
| Set Piece xGD | float | Set piece xG difference: `Set Piece xG - Set Piece xGA` |
| npxG | float | Non-penalty expected goals **for** the team |
| npxGA | float | Non-penalty expected goals **against** the team |
| npxGD | float | Non-penalty xG difference: `npxG - npxGA` |
| Goals | int | Goals scored by the team |
| Goals Conceded | int | Goals conceded by the team |
| GD | int | Goal difference: `Goals - Goals Conceded` |
| GD-xGD | float | Over/under-performance vs xG: `GD - xGD` |
| Possession | float | Possession share/percentage for the team |
| Field Tilt | float | Territorial dominance proxy (provider-specific definition) |
| Avg Pass Height | float | Average vertical height/field position of passes (directness/territory proxy) |
| xT | float | Expected threat created (progression value leading to future chances) |
| xT Against | float | Expected threat conceded to the opponent |
| Passes in Opposition Half | int | Passes played in the opponent half |
| Passes into Box | int | Passes played into the penalty box |
| Shots | int | Shots taken |
| Shots Faced | int | Shots conceded |
| Shots per 1.0 xT | float | Shot generation efficiency: `Shots / xT` |
| Shots Faced per 1.0 xT Against | float | Threat-to-shot conversion conceded: `Shots Faced / xT Against` |
| PPDA | float | Pressing intensity proxy (*lower = more intense press*, typically) |
| High Recoveries | int | Ball recoveries in advanced areas (high press success proxy) |
| High Recoveries Against | int | High recoveries conceded (opponent wins ball high vs this team) |
| Crosses | int | Crosses attempted/delivered (provider definition) |
| Corners | int | Corners won/earned |
| Fouls | int | Fouls committed |
| On-Ball Pressure | float | Pressure actions applied to the ball carrier (volume) |
| On-Ball Pressure Share | float | Share of pressure actions that are on-ball |
| Off-Ball Pressure | float | Pressure actions applied away from the ball (volume) |
| Off-Ball Pressure Share | float | Share of pressure actions that are off-ball |
| Game Control | float | Control/dominance proxy metric (provider-specific composite) |
| Game Control Share | float | Share of overall game control attributed to the team |
| Throw-Ins into the Box | int | Throw-ins delivered into the penalty box |

---

## Planned Derived Fields (created later in ETL)

From `Match`:
- `home_team`, `away_team`
- `home_goals`, `away_goals`
- `is_home` (boolean)
- `opponent`

From goals/result:
- `goals_for`, `goals_against`
- `result` (*W/D/L*)
- `points` (*3/1/0*)

Identifiers:
- `match_id` (unique game identifier)

Additional derived metrics:
- `xT_diff = xT - xT Against`
- `shot_quality = xG / Shots`
- `shot_quality_conceded = xGA / Shots Faced`
