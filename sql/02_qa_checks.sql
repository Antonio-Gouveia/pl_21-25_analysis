-- sql/02_qa_checks.sql
USE pl_21_25;

-- 1) basic counts
SELECT 'dim_season' AS t, COUNT(*) AS c FROM dim_season
UNION ALL SELECT 'dim_team', COUNT(*) FROM dim_team
UNION ALL SELECT 'dim_match', COUNT(*) FROM dim_match
UNION ALL SELECT 'fact_team_match', COUNT(*) FROM fact_team_match;

-- 2) orphan checks (should all be 0)
SELECT COUNT(*) AS orphan_season
FROM fact_team_match f
LEFT JOIN dim_season s ON f.season_id = s.season_id
WHERE s.season_id IS NULL;

SELECT COUNT(*) AS orphan_team
FROM fact_team_match f
LEFT JOIN dim_team t ON f.team_id = t.team_id
WHERE t.team_id IS NULL;

SELECT COUNT(*) AS orphan_match
FROM fact_team_match f
LEFT JOIN dim_match m ON f.match_id = m.match_id
WHERE m.match_id IS NULL;

-- 3) each match_id should appear exactly 2 times in fact
SELECT MIN(cnt) AS min_cnt, MAX(cnt) AS max_cnt
FROM (
  SELECT match_id, COUNT(*) cnt
  FROM fact_team_match
  GROUP BY match_id
) x;
