CREATE TABLE IF NOT EXISTS summary_2020 (
	reported_year INT,
	district TEXT,
	avg_off_age DECIMAL,
	avg_offender_number DECIMAL,
	offender_race TEXT,
	offender_gender TEXT,
	avg_vict_age DECIMAL,
	avg_victim_number DECIMAL,
	victim_race TEXT,
	victim_gender TEXT
);



--- District with most incident by year
INSERT INTO summary_2020
WITH reports_by_dist_by_year AS ( 
	SELECT 
		EXTRACT(YEAR FROM report_date) AS reported_year,
		district,
		COUNT(DISTINCT report_id) AS total_cases
	FROM police_reports
	GROUP BY EXTRACT(YEAR FROM report_date), district
),
max_cases_by_year AS (
    SELECT
        reported_year,
        MAX(total_cases) AS max_cases
    FROM reports_by_dist_by_year
    GROUP BY reported_year
),
offender_race_count AS (
SELECT
	year,
	offender_race,
	count_off_race
FROM (
	SELECT
		EXTRACT (YEAR FROM occurred_date_time) AS year,
		offender_race,
		COUNT(offender_race) AS count_off_race,
		ROW_NUMBER() OVER (
			PARTITION BY EXTRACT (YEAR FROM occurred_date_time)
			ORDER BY COUNT(offender_race) DESC
		) AS rn
	FROM police_reports_2020
	WHERE offender_race != 'NULL'
	GROUP BY EXTRACT (YEAR FROM occurred_date_time), offender_race
	)
WHERE rn = 1
),
offender_gender_count AS (
SELECT
	year,
	offender_gender,
	count_off_gender
FROM (
	SELECT 
		EXTRACT (YEAR FROM occurred_date_time) AS year,
		offender_gender,
		COUNT(offender_gender) AS count_off_gender,
		ROW_NUMBER() OVER (
			PARTITION BY EXTRACT (YEAR FROM occurred_date_time)
			ORDER BY COUNT(offender_gender) DESC
		) AS rn
	FROM police_reports_2020
	WHERE offender_gender != 'NULL'
	GROUP BY EXTRACT (YEAR FROM occurred_date_time), offender_gender
)
WHERE rn = 1
),
victim_race_count AS (
SELECT
	year,
	victim_race,
	count_vict_race
FROM (
	SELECT
		EXTRACT (YEAR FROM occurred_date_time) AS year,
		victim_race,
		COUNT(victim_race) AS count_vict_race,
		ROW_NUMBER() OVER (
			PARTITION BY EXTRACT (YEAR FROM occurred_date_time)
			ORDER BY COUNT(victim_race) DESC
		) AS rn
	FROM police_reports_2020
	WHERE victim_race != 'NULL'
	GROUP BY EXTRACT (YEAR FROM occurred_date_time), victim_race
	)
WHERE rn = 1
),
victim_gender_count AS (
SELECT
	year,
	victim_gender,
	count_vict_gender
FROM (
	SELECT 
		EXTRACT (YEAR FROM occurred_date_time) AS year,
		victim_gender,
		COUNT(victim_gender) AS count_vict_gender,
		ROW_NUMBER() OVER (
			PARTITION BY EXTRACT (YEAR FROM occurred_date_time)
			ORDER BY COUNT(victim_gender) DESC
		) AS rn
	FROM police_reports_2020
	WHERE victim_gender != 'NULL'
	GROUP BY EXTRACT (YEAR FROM occurred_date_time), victim_gender
)
WHERE rn = 1
),
most_reported_districts AS (
	SELECT
		rdy.reported_year AS year,
		rdy.district
	FROM reports_by_dist_by_year rdy
	INNER JOIN max_cases_by_year mcy
		ON rdy.reported_year = mcy.reported_year
		AND rdy.total_cases = mcy.max_cases
),

------------------------------- Offender Summary
offender_info AS (
	SELECT
		EXTRACT (YEAR FROM pr.occurred_date_time) AS year,
		ROUND(AVG(NULLIF(pr.offender_age, 'NULL')::INT),2) AS avg_off_age,
	    ROUND(AVG(NULLIF(pr.offender_number, 'NULL')::INT),2) AS avg_offender_number,
	    orc.offender_race,
	    ogc.offender_gender
	FROM police_reports_2020 pr
	INNER JOIN offender_race_count orc
		ON EXTRACT (YEAR FROM pr.occurred_date_time) = orc.year
	INNER JOIN offender_gender_count ogc
		ON EXTRACT (YEAR FROM pr.occurred_date_time) = ogc.year
	GROUP BY EXTRACT (YEAR FROM occurred_date_time), orc.offender_race, ogc.offender_gender
	ORDER BY year
),

--------------------------------------------- Victim Summary
victim_info AS (
SELECT
	EXTRACT (YEAR FROM pr.occurred_date_time) AS year,
	ROUND(AVG(NULLIF(pr.victim_age, 'NULL')::INT),2) AS avg_vict_age,
    ROUND(AVG(NULLIF(pr.victim_number, 'NULL')::INT),2) AS avg_victim_number,
    orc.victim_race,
    ogc.victim_gender
FROM police_reports_2020 pr
INNER JOIN victim_race_count orc
	ON EXTRACT (YEAR FROM pr.occurred_date_time) = orc.year
INNER JOIN victim_gender_count ogc
	ON EXTRACT (YEAR FROM pr.occurred_date_time) = ogc.year
GROUP BY EXTRACT (YEAR FROM occurred_date_time), orc.victim_race, ogc.victim_gender
ORDER BY year
)
SELECT 
	mrd.year AS reported_year,
	mrd.district,
	oi.avg_off_age,
	oi.avg_offender_number,
	oi.offender_race,
	oi.offender_gender,
	vi.avg_vict_age,
	vi.avg_victim_number,
	vi.victim_race,
	vi.victim_gender
FROM most_reported_districts mrd
INNER JOIN offender_info oi 
	ON mrd.year = oi.year
INNER JOIN victim_info vi 
	ON mrd.year = vi.year