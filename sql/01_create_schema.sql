-- sql/01_create_schema.sql
CREATE DATABASE IF NOT EXISTS pl_21_25
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;

USE pl_21_25;

-- -------------------------
-- Dimensions
-- -------------------------
CREATE TABLE IF NOT EXISTS dim_season (
  season_id INT PRIMARY KEY,
  season VARCHAR(10) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS dim_team (
  team_id INT PRIMARY KEY,
  team_name VARCHAR(80) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS dim_match (
  match_id VARCHAR(120) PRIMARY KEY,
  season_id INT NOT NULL,
  match_date DATE NOT NULL,
  home_team_id INT NOT NULL,
  away_team_id INT NOT NULL,
  home_goals INT NULL,
  away_goals INT NULL,
  match_label VARCHAR(200) NULL,

  CONSTRAINT fk_match_season
    FOREIGN KEY (season_id) REFERENCES dim_season(season_id),

  CONSTRAINT fk_match_home_team
    FOREIGN KEY (home_team_id) REFERENCES dim_team(team_id),

  CONSTRAINT fk_match_away_team
    FOREIGN KEY (away_team_id) REFERENCES dim_team(team_id),

  INDEX idx_match_season_date (season_id, match_date),
  INDEX idx_match_home (home_team_id),
  INDEX idx_match_away (away_team_id)
) ENGINE=InnoDB;

-- -------------------------
-- Fact
-- -------------------------
CREATE TABLE IF NOT EXISTS fact_team_match (
  match_id VARCHAR(120) NOT NULL,
  season_id INT NOT NULL,
  team_id INT NOT NULL,
  opponent_team_id INT NOT NULL,
  is_home TINYINT NOT NULL,

  -- base match outcomes
  goals_for INT NULL,
  goals_against INT NULL,
  result CHAR(1) NULL,
  points INT NULL,

  -- original metrics (snake_case)
  xg DOUBLE NULL,
  xga DOUBLE NULL,
  xgd DOUBLE NULL,

  open_play_xg DOUBLE NULL,
  open_play_xga DOUBLE NULL,
  open_play_xgd DOUBLE NULL,

  set_piece_xg DOUBLE NULL,
  set_piece_xga DOUBLE NULL,
  set_piece_xgd DOUBLE NULL,

  npxg DOUBLE NULL,
  npxga DOUBLE NULL,
  npxgd DOUBLE NULL,

  goals INT NULL,
  goals_conceded INT NULL,
  gd INT NULL,
  gd_minus_xgd DOUBLE NULL,

  possession DOUBLE NULL,
  field_tilt DOUBLE NULL,
  avg_pass_height DOUBLE NULL,

  xt DOUBLE NULL,
  xt_against DOUBLE NULL,

  passes_in_opposition_half INT NULL,
  passes_into_box INT NULL,
  shots INT NULL,
  shots_faced INT NULL,

  shots_per_1_0_xt DOUBLE NULL,
  shots_faced_per_1_0_xt_against DOUBLE NULL,

  ppda DOUBLE NULL,
  high_recoveries INT NULL,
  high_recoveries_against INT NULL,
  crosses INT NULL,
  corners INT NULL,
  fouls INT NULL,

  on_ball_pressure DOUBLE NULL,
  on_ball_pressure_share DOUBLE NULL,
  off_ball_pressure DOUBLE NULL,
  off_ball_pressure_share DOUBLE NULL,

  game_control DOUBLE NULL,
  game_control_share DOUBLE NULL,
  throw_ins_into_box INT NULL,

  -- derived metrics
  xt_diff DOUBLE NULL,
  shot_quality DOUBLE NULL,
  shot_quality_conceded DOUBLE NULL,

  PRIMARY KEY (match_id, team_id),

  CONSTRAINT fk_fact_match
    FOREIGN KEY (match_id) REFERENCES dim_match(match_id),

  CONSTRAINT fk_fact_season
    FOREIGN KEY (season_id) REFERENCES dim_season(season_id),

  CONSTRAINT fk_fact_team
    FOREIGN KEY (team_id) REFERENCES dim_team(team_id),

  CONSTRAINT fk_fact_opp_team
    FOREIGN KEY (opponent_team_id) REFERENCES dim_team(team_id),

  CONSTRAINT chk_is_home CHECK (is_home IN (0,1)),
  CONSTRAINT chk_result CHECK (result IN ('W','D','L')),

  INDEX idx_fact_season_team (season_id, team_id),
  INDEX idx_fact_match (match_id),
  INDEX idx_fact_team (team_id),
  INDEX idx_fact_opponent (opponent_team_id)
) ENGINE=InnoDB;

USE pl_21_25;

SELECT 'dim_season' AS t, COUNT(*) c FROM dim_season
UNION ALL SELECT 'dim_team', COUNT(*) FROM dim_team
UNION ALL SELECT 'dim_match', COUNT(*) FROM dim_match
UNION ALL SELECT 'fact_team_match', COUNT(*) FROM fact_team_match;
