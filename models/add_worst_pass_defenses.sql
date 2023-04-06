with
  qbr_rank as (
    SELECT
      season,
      opp_team as team,
      ROUND(AVG(CAST(qbr_total AS DOUBLE)), 2) as avg_qbr,
      ROW_NUMBER() OVER (
        PARTITION BY
          season
        ORDER BY
          AVG(CAST(qbr_total AS DOUBLE)) desc
      ) AS pass_defense_rank
    FROM
      qbr
    WHERE
      season_type = 'Regular'
    group by
      1,
      2
  )
SELECT
  season,
  team,
  avg_qbr,
  pass_defense_rank
FROM
  qbr_rank
WHERE
  pass_defense_rank <= 10
ORDER BY
  season DESC,
  avg_qbr DESC;
