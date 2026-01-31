USE pl_21_25;

-- Re-run safe (no tables dropped)
DROP VIEW IF EXISTS v_fact_team_match;
DROP VIEW IF EXISTS v_dim_match;
DROP VIEW IF EXISTS v_dim_team;
DROP VIEW IF EXISTS v_dim_season;

CREATE VIEW v_dim_season AS
SELECT
  season_id,
  season
FROM dim_season;

CREATE VIEW v_dim_team AS
SELECT
  team_id,
  team_name
FROM dim_team;

CREATE VIEW v_dim_match AS
SELECT
  match_id,
  season_id,
  match_date,
  home_team_id,
  away_team_id,
  home_goals,
  away_goals,
  match_label
FROM dim_match;

CREATE VIEW v_fact_team_match AS
SELECT
  match_id,
  season_id,
  team_id,
  opponent_team_id,
  is_home,

  `xG` AS xg,
  `xGA` AS xga,
  `xGD` AS xgd,

  `Open Play xG`  AS open_play_xg,
  `Open Play xGA` AS open_play_xga,
  `Open Play xGD` AS open_play_xgd,

  `Set Piece xG`  AS set_piece_xg,
  `Set Piece xGA` AS set_piece_xga,
  `Set Piece xGD` AS set_piece_xgd,

  `npxG`  AS npxg,
  `npxGA` AS npxga,
  `npxGD` AS npxgd,

  `Goals`          AS goals,
  `Goals Conceded` AS goals_conceded,
  `GD`             AS gd,
  `GD-xGD`         AS gd_minus_xgd,

  `Possession`       AS possession,
  `Field Tilt`       AS field_tilt,
  `Avg Pass Height`  AS avg_pass_height,

  `xT`         AS xt,
  `xT Against` AS xt_against,

  `Passes in Opposition Half` AS passes_in_opposition_half,
  `Passes into Box`           AS passes_into_box,
  `Shots`                     AS shots,
  `Shots Faced`               AS shots_faced,

  `Shots per 1.0 xT`                  AS shots_per_1_0_xt,
  `Shots Faced per 1.0 xT Against`    AS shots_faced_per_1_0_xt_against,

  `PPDA`                    AS ppda,
  `High Recoveries`         AS high_recoveries,
  `High Recoveries Against` AS high_recoveries_against,
  `Crosses`                 AS crosses,
  `Corners`                 AS corners,
  `Fouls`                   AS fouls,

  `On-Ball Pressure`        AS on_ball_pressure,
  `On-Ball Pressure Share`  AS on_ball_pressure_share,
  `Off-Ball Pressure`       AS off_ball_pressure,
  `Off-Ball Pressure Share` AS off_ball_pressure_share,

  `Game Control`       AS game_control,
  `Game Control Share` AS game_control_share,

  `Throw-Ins into the Box` AS throw_ins_into_box,

  home_goals,
  away_goals,
  goals_for,
  goals_against,
  result,
  points,

  xT_diff AS xt_diff,
  shot_quality,
  shot_quality_conceded

FROM fact_team_match;


USE pl_21_25;

SHOW FULL TABLES WHERE Table_type = 'VIEW';

SELECT COUNT(*) AS n FROM v_fact_team_match;          -- esperado: 3040
SELECT open_play_xg FROM v_fact_team_match LIMIT 5;   -- deve aparecer uma coluna com valores
