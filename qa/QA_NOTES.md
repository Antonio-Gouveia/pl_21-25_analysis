# QA Notes — Premier League Matchlist (21-22 to 24-25)

This QA validates the per-season integrity of the enriched datasets (`*_v4.csv`).

## Checks

- 760 rows per season (20 teams × 38 matches)

- 380 unique `match_id` per season

- Each `match_id` appears exactly 2 times (home team + away team perspectives)

- Points sum per match is 3 (win/loss) or 2 (draw)

- Each team has exactly 38 games per season

- Exactly 20 teams per season


## Summary table

| season   | file                      |   rows | rows_ok_760   |   unique_match_id | unique_match_ok_380   |   match_id_eq_2 |   match_id_not_2 | match_id_all_eq_2   |   points_invalid_matches | points_per_match_ok   |   unique_teams | teams_ok_20   |   teams_with_38_games |   teams_not_38_count | team_games_ok_38   |
|:---------|:--------------------------|-------:|:--------------|------------------:|:----------------------|----------------:|-----------------:|:--------------------|-------------------------:|:----------------------|---------------:|:--------------|----------------------:|---------------------:|:-------------------|
| 21-22    | pl_matchlist_21-22_v4.csv |    760 | True          |               380 | True                  |             380 |                0 | True                |                        0 | True                  |             20 | True          |                    20 |                    0 | True               |
| 22-23    | pl_matchlist_22-23_v4.csv |    760 | True          |               380 | True                  |             380 |                0 | True                |                        0 | True                  |             20 | True          |                    20 |                    0 | True               |
| 23-24    | pl_matchlist_23-24_v4.csv |    760 | True          |               380 | True                  |             380 |                0 | True                |                        0 | True                  |             20 | True          |                    20 |                    0 | True               |
| 24-25    | pl_matchlist_24-25_v4.csv |    760 | True          |               380 | True                  |             380 |                0 | True                |                        0 | True                  |             20 | True          |                    20 |                    0 | True               |


## Issues
✅ No issues found.
