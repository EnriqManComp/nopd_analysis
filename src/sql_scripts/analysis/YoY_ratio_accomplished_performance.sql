CREATE TABLE IF NOT EXISTS yoy_ratio_accomplished_closed_cases_perf (
	reported_year INT,
	district TEXT,
	charge_description TEXT,
	total_reports INT,
	total_closed_cases INT,
	ratio_closed_cases DECIMAL,
	target_closed_cases DECIMAL,
	ratio_accomplish_closed_cases DECIMAL,
	YoY_ratio_accomplished_performance DECIMAL
);

INSERT INTO yoy_ratio_accomplished_closed_cases_perf
WITH closed_cases_report AS (
	SELECT 
		EXTRACT (YEAR FROM report_date) AS reported_year,
		district,
		charge_description,
		COUNT(DISTINCT report_id) AS total_reports,
		COUNT(*) FILTER (WHERE disposition = 'CLOSED') AS total_closed_cases,
		ROUND(
	        COUNT(*) FILTER (WHERE disposition = 'CLOSED')::numeric 
	        / NULLIF(
	            COUNT(DISTINCT report_id), 
	            0
	        ),
	        4
	    ) AS ratio_closed_cases,
	    0.9*COUNT(DISTINCT report_id)::DECIMAL AS target_closed_cases,
	    ROUND(
	        COUNT(*) FILTER (WHERE disposition = 'CLOSED')::numeric 
	        / NULLIF(
	            0.9*COUNT(DISTINCT report_id)::DECIMAL, 
	            0
	        ),
	        4
	    ) AS ratio_accomplish_closed_cases
	FROM police_reports
	GROUP BY EXTRACT (YEAR FROM report_date), district, charge_description
)
SELECT
    *,
    ratio_accomplish_closed_cases
        - LAG(ratio_accomplish_closed_cases, 1)
          OVER (PARTITION BY district, charge_description ORDER BY reported_year)
        AS yoy_ratio_accomplished_performance
FROM closed_cases_report;

SELECT *
FROM yoy_ratio_accomplished_closed_cases_perf yraccp 