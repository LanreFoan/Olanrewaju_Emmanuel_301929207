WITH measurements(stage, run_number, execution_ms, evidence) AS (
  VALUES
    ('before', 1, 13.682::numeric, 'screenshot shows Seq Scan'),
    ('before', 2, 13.682::numeric, 'reported second run; distinct execution unconfirmed'),
    ('before', 3, 22.006::numeric, 'screenshot shows Seq Scan'),
    ('after',  1, 0.512::numeric, 'student-reported'),
    ('after',  2, 0.314::numeric, 'student-reported'),
    ('after',  3, 0.186::numeric, 'student-reported')
)
SELECT stage, run_number, execution_ms, evidence
FROM measurements
ORDER BY CASE WHEN stage='before' THEN 0 ELSE 1 END, run_number;

-- Provisional averages and comparison using above classification.
WITH measurements(stage, execution_ms) AS (
  VALUES
    ('before', 13.682::numeric), ('before', 13.682::numeric),
    ('before', 22.006::numeric), ('after', 0.512::numeric),
    ('after', 0.314::numeric), ('after', 0.186::numeric)
), means AS (
  SELECT AVG(execution_ms) FILTER (WHERE stage='before') AS before_avg_ms,
         AVG(execution_ms) FILTER (WHERE stage='after') AS after_avg_ms
  FROM measurements
)
SELECT ROUND(before_avg_ms,3) AS before_avg_ms,
       ROUND(after_avg_ms,3) AS after_avg_ms,
       ROUND(100*(before_avg_ms-after_avg_ms)/before_avg_ms,2) AS time_reduction_percent,
       ROUND(before_avg_ms/after_avg_ms,2) AS speedup_factor
FROM means;
