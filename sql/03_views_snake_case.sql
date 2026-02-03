USE pl_21_25;

-- ============================================================
-- 0) Re-run safe: drop views (drop dependentes primeiro)
-- ============================================================
DROP VIEW IF EXISTS v_style_clustering_input;
DROP VIEW IF EXISTS v_league_benchmarks_season;
DROP VIEW IF EXISTS v_team_season_style_profile;
DROP VIEW IF EXISTS v_team_match_enriched;

DROP VIEW IF EXISTS v_fact_team_match;

DROP VIEW IF EXISTS v_dim_match;
DROP VIEW IF EXISTS v_dim_team;
DROP VIEW IF EXISTS v_dim_season;

-- ============================================================
-- 1) Optional "clean" dim views (snake_case + nomes consistentes)
-- ============================================================
CREATE VIEW v_dim_season AS
SELECT season_id, season
FROM dim_season;

CREATE VIEW v_dim_team AS
SELECT team_id, team_name
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

-- ============================================================
-- 2) Base view: fact_team_match em snake_case (evita colunas com espaços no Tableau)
-- ============================================================
CREATE VIEW v_fact_team_match AS
SELECT
  match_id,
  season_id,
  team_id,
  opponent_team_id,
  is_home,

  `xG`  AS xg,
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

  `Possession`      AS possession,
  `Field Tilt`      AS field_tilt,
  `Avg Pass Height` AS avg_pass_height,

  `xT`         AS xt,
  `xT Against` AS xt_against,

  `Passes in Opposition Half` AS passes_in_opposition_half,
  `Passes into Box`           AS passes_into_box,

  `Shots`       AS shots,
  `Shots Faced` AS shots_faced,

  `Shots per 1.0 xT`               AS shots_per_1_0_xt,
  `Shots Faced per 1.0 xT Against` AS shots_faced_per_1_0_xt_against,

  `PPDA` AS ppda,

  `High Recoveries`         AS high_recoveries,
  `High Recoveries Against` AS high_recoveries_against,

  `Crosses`  AS crosses,
  `Corners`  AS corners,
  `Fouls`    AS fouls,

  `On-Ball Pressure`       AS on_ball_pressure,
  `On-Ball Pressure Share` AS on_ball_pressure_share,

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

-- ============================================================
-- 3) v_team_match_enriched (match-level pronto para BI / Tableau)
-- ============================================================
CREATE VIEW v_team_match_enriched AS
SELECT
  s.season_id,
  s.season,

  m.match_id,
  m.match_date,
  m.match_label,

  m.home_team_id,
  ht.team_name AS home_team_name,
  m.away_team_id,
  at.team_name AS away_team_name,
  m.home_goals,
  m.away_goals,

  f.team_id,
  t.team_name,
  f.opponent_team_id,
  ot.team_name AS opponent_team_name,

  f.is_home,
  f.goals_for,
  f.goals_against,
  f.result,
  f.points,

  -- core x* + threat
  f.xg, f.xga, f.xgd,
  f.open_play_xg, f.open_play_xga, f.open_play_xgd,
  f.set_piece_xg, f.set_piece_xga, f.set_piece_xgd,
  f.npxg, f.npxga, f.npxgd,

  -- control / territory
  f.possession,
  f.field_tilt,
  f.game_control,
  f.game_control_share,

  -- press
  f.ppda,
  f.high_recoveries,
  f.high_recoveries_against,
  f.on_ball_pressure,
  f.on_ball_pressure_share,
  f.off_ball_pressure,
  f.off_ball_pressure_share,

  -- directness
  f.avg_pass_height,
  f.crosses,

  -- entries / creation
  f.xt,
  f.xt_against,
  f.xt_diff,
  f.passes_in_opposition_half,
  f.passes_into_box,

  -- shooting proxies
  f.shots,
  f.shots_faced,
  f.shots_per_1_0_xt,
  f.shots_faced_per_1_0_xt_against,
  f.shot_quality,
  f.shot_quality_conceded,

  -- set pieces extras
  f.corners,
  f.throw_ins_into_box

FROM v_fact_team_match f
JOIN dim_match  m  ON m.match_id  = f.match_id
JOIN dim_season s  ON s.season_id = f.season_id
JOIN dim_team   t  ON t.team_id   = f.team_id
JOIN dim_team   ot ON ot.team_id  = f.opponent_team_id
JOIN dim_team   ht ON ht.team_id  = m.home_team_id
JOIN dim_team   at ON at.team_id  = m.away_team_id;

-- ============================================================
-- 4) v_team_season_style_profile (médias por equipa×época)
-- ============================================================
CREATE VIEW v_team_season_style_profile AS
SELECT
  f.season_id,
  s.season,
  f.team_id,
  t.team_name,
  COUNT(*) AS matches_played,

  AVG(f.possession)         AS possession,
  AVG(f.field_tilt)         AS field_tilt,
  AVG(f.game_control_share) AS game_control_share,

  AVG(f.ppda)                    AS ppda,
  AVG(f.high_recoveries)         AS high_recoveries,
  AVG(f.on_ball_pressure_share)  AS on_ball_pressure_share,
  AVG(f.off_ball_pressure_share) AS off_ball_pressure_share,

  AVG(f.xt)             AS xt,
  AVG(f.xt_diff)        AS xt_diff,
  AVG(f.passes_into_box) AS passes_into_box,
  AVG(f.shots_per_1_0_xt) AS shots_per_1_0_xt,

  AVG(f.avg_pass_height) AS avg_pass_height,
  AVG(f.crosses)         AS crosses,

  AVG(f.set_piece_xg)      AS set_piece_xg,
  AVG(f.corners)           AS corners,
  AVG(f.throw_ins_into_box) AS throw_ins_into_box,

  AVG(f.xgd) AS xgd

FROM v_fact_team_match f
JOIN dim_season s ON s.season_id = f.season_id
JOIN dim_team   t ON t.team_id   = f.team_id
GROUP BY f.season_id, s.season, f.team_id, t.team_name;

-- ============================================================
-- 5) v_league_benchmarks_season (percentis/benchmarks por época)
--    nearest-rank via ROW_NUMBER (p10/p25/p50/p75/p90)
-- ============================================================
CREATE VIEW v_league_benchmarks_season AS
WITH base AS (
  SELECT season_id, season, 'possession' AS metric, possession AS value FROM v_team_season_style_profile
  UNION ALL SELECT season_id, season, 'field_tilt', field_tilt FROM v_team_season_style_profile
  UNION ALL SELECT season_id, season, 'game_control_share', game_control_share FROM v_team_season_style_profile
  UNION ALL SELECT season_id, season, 'ppda', ppda FROM v_team_season_style_profile
  UNION ALL SELECT season_id, season, 'high_recoveries', high_recoveries FROM v_team_season_style_profile
  UNION ALL SELECT season_id, season, 'on_ball_pressure_share', on_ball_pressure_share FROM v_team_season_style_profile
  UNION ALL SELECT season_id, season, 'off_ball_pressure_share', off_ball_pressure_share FROM v_team_season_style_profile
  UNION ALL SELECT season_id, season, 'xt', xt FROM v_team_season_style_profile
  UNION ALL SELECT season_id, season, 'xt_diff', xt_diff FROM v_team_season_style_profile
  UNION ALL SELECT season_id, season, 'passes_into_box', passes_into_box FROM v_team_season_style_profile
  UNION ALL SELECT season_id, season, 'shots_per_1_0_xt', shots_per_1_0_xt FROM v_team_season_style_profile
  UNION ALL SELECT season_id, season, 'avg_pass_height', avg_pass_height FROM v_team_season_style_profile
  UNION ALL SELECT season_id, season, 'crosses', crosses FROM v_team_season_style_profile
  UNION ALL SELECT season_id, season, 'set_piece_xg', set_piece_xg FROM v_team_season_style_profile
  UNION ALL SELECT season_id, season, 'corners', corners FROM v_team_season_style_profile
  UNION ALL SELECT season_id, season, 'throw_ins_into_box', throw_ins_into_box FROM v_team_season_style_profile
  UNION ALL SELECT season_id, season, 'xgd', xgd FROM v_team_season_style_profile
),
ranked AS (
  SELECT
    season_id,
    season,
    metric,
    value,
    ROW_NUMBER() OVER (PARTITION BY season_id, metric ORDER BY value) AS rn,
    COUNT(*)    OVER (PARTITION BY season_id, metric) AS n
  FROM base
  WHERE value IS NOT NULL
)
SELECT
  season_id,
  season,
  metric,
  MAX(CASE WHEN rn = GREATEST(1, CEIL(0.10*n)) THEN value END) AS p10,
  MAX(CASE WHEN rn = GREATEST(1, CEIL(0.25*n)) THEN value END) AS p25,
  MAX(CASE WHEN rn = GREATEST(1, CEIL(0.50*n)) THEN value END) AS p50,
  MAX(CASE WHEN rn = GREATEST(1, CEIL(0.75*n)) THEN value END) AS p75,
  MAX(CASE WHEN rn = GREATEST(1, CEIL(0.90*n)) THEN value END) AS p90,
  n AS n_teams
FROM ranked
GROUP BY season_id, season, metric, n;

-- ============================================================
-- 6) v_style_clustering_input (team×season com features normalizadas por época)
--    raw + z-score + percent_rank (0-100)
--    Nota: ppda_inv = -ppda (maior = pressiona mais)
-- ============================================================
CREATE VIEW v_style_clustering_input AS
SELECT
  season_id,
  season,
  team_id,
  team_name,
  matches_played,

  possession,
  field_tilt,
  game_control_share,
  ppda,
  high_recoveries,
  on_ball_pressure_share,
  off_ball_pressure_share,
  xt,
  passes_into_box,
  shots_per_1_0_xt,
  avg_pass_height,
  crosses,
  set_piece_xg,
  corners,
  throw_ins_into_box,
  xgd,

  (-ppda) AS ppda_inv,

  -- z-scores (within season)
  (possession - AVG(possession) OVER (PARTITION BY season_id)) / NULLIF(STDDEV_SAMP(possession) OVER (PARTITION BY season_id), 0) AS z_possession,
  (field_tilt - AVG(field_tilt) OVER (PARTITION BY season_id)) / NULLIF(STDDEV_SAMP(field_tilt) OVER (PARTITION BY season_id), 0) AS z_field_tilt,
  (game_control_share - AVG(game_control_share) OVER (PARTITION BY season_id)) / NULLIF(STDDEV_SAMP(game_control_share) OVER (PARTITION BY season_id), 0) AS z_game_control_share,
  ((-ppda) - AVG(-ppda) OVER (PARTITION BY season_id)) / NULLIF(STDDEV_SAMP(-ppda) OVER (PARTITION BY season_id), 0) AS z_ppda_inv,
  (high_recoveries - AVG(high_recoveries) OVER (PARTITION BY season_id)) / NULLIF(STDDEV_SAMP(high_recoveries) OVER (PARTITION BY season_id), 0) AS z_high_recoveries,
  (on_ball_pressure_share - AVG(on_ball_pressure_share) OVER (PARTITION BY season_id)) / NULLIF(STDDEV_SAMP(on_ball_pressure_share) OVER (PARTITION BY season_id), 0) AS z_on_ball_pressure_share,
  (off_ball_pressure_share - AVG(off_ball_pressure_share) OVER (PARTITION BY season_id)) / NULLIF(STDDEV_SAMP(off_ball_pressure_share) OVER (PARTITION BY season_id), 0) AS z_off_ball_pressure_share,
  (xt - AVG(xt) OVER (PARTITION BY season_id)) / NULLIF(STDDEV_SAMP(xt) OVER (PARTITION BY season_id), 0) AS z_xt,
  (passes_into_box - AVG(passes_into_box) OVER (PARTITION BY season_id)) / NULLIF(STDDEV_SAMP(passes_into_box) OVER (PARTITION BY season_id), 0) AS z_passes_into_box,
  (shots_per_1_0_xt - AVG(shots_per_1_0_xt) OVER (PARTITION BY season_id)) / NULLIF(STDDEV_SAMP(shots_per_1_0_xt) OVER (PARTITION BY season_id), 0) AS z_shots_per_1_0_xt,
  (avg_pass_height - AVG(avg_pass_height) OVER (PARTITION BY season_id)) / NULLIF(STDDEV_SAMP(avg_pass_height) OVER (PARTITION BY season_id), 0) AS z_avg_pass_height,
  (crosses - AVG(crosses) OVER (PARTITION BY season_id)) / NULLIF(STDDEV_SAMP(crosses) OVER (PARTITION BY season_id), 0) AS z_crosses,
  (set_piece_xg - AVG(set_piece_xg) OVER (PARTITION BY season_id)) / NULLIF(STDDEV_SAMP(set_piece_xg) OVER (PARTITION BY season_id), 0) AS z_set_piece_xg,
  (corners - AVG(corners) OVER (PARTITION BY season_id)) / NULLIF(STDDEV_SAMP(corners) OVER (PARTITION BY season_id), 0) AS z_corners,
  (throw_ins_into_box - AVG(throw_ins_into_box) OVER (PARTITION BY season_id)) / NULLIF(STDDEV_SAMP(throw_ins_into_box) OVER (PARTITION BY season_id), 0) AS z_throw_ins_into_box,
  (xgd - AVG(xgd) OVER (PARTITION BY season_id)) / NULLIF(STDDEV_SAMP(xgd) OVER (PARTITION BY season_id), 0) AS z_xgd,

  -- percentiles (0-100 within season)
  100 * PERCENT_RANK() OVER (PARTITION BY season_id ORDER BY possession)         AS pct_possession,
  100 * PERCENT_RANK() OVER (PARTITION BY season_id ORDER BY field_tilt)         AS pct_field_tilt,
  100 * PERCENT_RANK() OVER (PARTITION BY season_id ORDER BY game_control_share) AS pct_game_control_share,
  100 * PERCENT_RANK() OVER (PARTITION BY season_id ORDER BY (-ppda))            AS pct_ppda_inv,
  100 * PERCENT_RANK() OVER (PARTITION BY season_id ORDER BY high_recoveries)    AS pct_high_recoveries,
  100 * PERCENT_RANK() OVER (PARTITION BY season_id ORDER BY on_ball_pressure_share)  AS pct_on_ball_pressure_share,
  100 * PERCENT_RANK() OVER (PARTITION BY season_id ORDER BY off_ball_pressure_share) AS pct_off_ball_pressure_share,
  100 * PERCENT_RANK() OVER (PARTITION BY season_id ORDER BY xt)                 AS pct_xt,
  100 * PERCENT_RANK() OVER (PARTITION BY season_id ORDER BY passes_into_box)    AS pct_passes_into_box,
  100 * PERCENT_RANK() OVER (PARTITION BY season_id ORDER BY shots_per_1_0_xt)   AS pct_shots_per_1_0_xt,
  100 * PERCENT_RANK() OVER (PARTITION BY season_id ORDER BY avg_pass_height)    AS pct_avg_pass_height,
  100 * PERCENT_RANK() OVER (PARTITION BY season_id ORDER BY crosses)            AS pct_crosses,
  100 * PERCENT_RANK() OVER (PARTITION BY season_id ORDER BY set_piece_xg)       AS pct_set_piece_xg,
  100 * PERCENT_RANK() OVER (PARTITION BY season_id ORDER BY corners)            AS pct_corners,
  100 * PERCENT_RANK() OVER (PARTITION BY season_id ORDER BY throw_ins_into_box) AS pct_throw_ins_into_box,
  100 * PERCENT_RANK() OVER (PARTITION BY season_id ORDER BY xgd)                AS pct_xgd

FROM v_team_season_style_profile;

-- ============================================================
-- 7) Sanity checks (Workbench)
-- ============================================================
SHOW FULL TABLES WHERE Table_type = 'VIEW';

SELECT COUNT(*) AS n_team_match_enriched FROM v_team_match_enriched;       -- esperado: 3040
SELECT COUNT(*) AS n_team_season_profile FROM v_team_season_style_profile; -- esperado: 80
SELECT COUNT(*) AS n_cluster_input FROM v_style_clustering_input;          -- esperado: 80

SELECT season, COUNT(*) AS n
FROM v_team_season_style_profile
GROUP BY season
ORDER BY season;

SELECT open_play_xg
FROM v_team_match_enriched
LIMIT 5;

-- Nota: no enriched o campo chama-se opponent_team_name (não "opponent_name")
SELECT season, match_date, team_name, opponent_team_name, is_home, goals_for, goals_against, points
FROM v_team_match_enriched
LIMIT 10;

