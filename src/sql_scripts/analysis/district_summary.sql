-- 
-- reported_year, 01/01/2010 X
-- most reported district,	 X
-- disposition ratio,		 X
-- most commited signal description X
-- most repeated offender race,		X
-- most repeated offender gender,	X
-- offender age avg					X		
-- offender number avg				X
-- most repeated victim race,		X
-- most repeated victim gender,		X
-- victim age avg					X
-- victim number avg				X
-- fatal status ratio				X
CREATE TABLE IF NOT EXISTS district_summary (
	reported_year INT,
	district TEXT,
	count_cases INT,
	closed_cases DECIMAL,
	signal_description TEXT,
	offender_race TEXT,
	offender_gender TEXT,
	offender_age_avg DECIMAL,
	offender_number_avg DECIMAL,
	victim_race TEXT,
	victim_gender TEXT,
	victim_age_avg DECIMAL,
	victim_number_avg DECIMAL,
	fatal_ratio DECIMAL,
	yoy_closed_cases DECIMAL
);
INSERT INTO district_summary
WITH _police_reports_2010_2025 AS (
	SELECT 
		occurred_date_time,
		district,
		item_number,
		disposition,
		signal_description,
		offender_race,
		offender_gender,
		offender_age,
		offender_number,
		victim_race,
		victim_gender,
		victim_age,
		victim_number,
		victim_fatal_status
	FROM police_reports_2010_2019
	UNION ALL
	SELECT 
		occurred_date_time,
		district,
		item_number,
		disposition,
		signal_description,
		offender_race,
		offender_gender,
		offender_age,
		offender_number,
		victim_race,
		victim_gender,
		victim_age,
		victim_number,
		victim_fatal_status
	FROM police_reports_2020
),
group_years AS (
    SELECT DISTINCT EXTRACT(YEAR FROM occurred_date_time)::int AS reported_year
    FROM _police_reports_2010_2025
),

-- Get distinct districts
group_districts AS (
    SELECT DISTINCT district
    FROM _police_reports_2010_2025
),
year_district AS (
	SELECT 
	    y.reported_year,
	    d.district
	FROM group_years y
	CROSS JOIN group_districts d
	ORDER BY y.reported_year, d.district
),
disposition_ratio AS (
	SELECT
		EXTRACT(YEAR FROM occurred_date_time) AS reported_year,
		district,
		COUNT(DISTINCT item_number) AS count_cases,
		COUNT(DISTINCT item_number) FILTER (WHERE disposition = 'CLOSED')::numeric AS closed_cases
	FROM _police_reports_2010_2025
	GROUP BY EXTRACT(YEAR FROM occurred_date_time), district
	ORDER BY reported_year, district
),
most_repeated_signal_description AS (
	SELECT 
		reported_year,
		district,
		signal_description
	FROM (
		SELECT 
			EXTRACT(YEAR FROM occurred_date_time) AS reported_year, district,
			signal_description,
			COUNT(signal_description),
			ROW_NUMBER() OVER (
				PARTITION BY EXTRACT(YEAR FROM occurred_date_time), district
				ORDER BY COUNT(signal_description) DESC
			) AS rn
		FROM _police_reports_2010_2025
		GROUP BY EXTRACT(YEAR FROM occurred_date_time), district, signal_description
	)
	WHERE rn = 1
	ORDER BY reported_year, district
),
most_repeated_offender_race AS (
	SELECT 
		reported_year,
		district,
		offender_race
	FROM (
		SELECT 
			EXTRACT(YEAR FROM occurred_date_time) AS reported_year,
			district, 
			offender_race,
			COUNT(offender_race),
			ROW_NUMBER() OVER (
				PARTITION BY EXTRACT(YEAR FROM occurred_date_time), district
				ORDER BY COUNT(offender_race) DESC
			) AS rn
		FROM _police_reports_2010_2025
		WHERE offender_race != 'NULL'
		GROUP BY EXTRACT(YEAR FROM occurred_date_time), district, offender_race
	)
	WHERE rn = 1
	ORDER BY reported_year, district
),
most_repeated_offender_gender AS (
	SELECT 
		reported_year,
		district,
		offender_gender
	FROM (
		SELECT 
			EXTRACT(YEAR FROM occurred_date_time) AS reported_year, district,
			offender_gender,
			COUNT(offender_gender),
			ROW_NUMBER() OVER (
				PARTITION BY EXTRACT(YEAR FROM occurred_date_time), district
				ORDER BY COUNT(offender_gender) DESC
			) AS rn
		FROM _police_reports_2010_2025
		WHERE offender_gender != 'NULL'
		GROUP BY EXTRACT(YEAR FROM occurred_date_time), district, offender_gender
	)
	WHERE rn = 1
	ORDER BY reported_year, district
),
offender_avg AS (
	SELECT 
		EXTRACT(YEAR FROM occurred_date_time) AS reported_year,
		district,
		ROUND(AVG(NULLIF(offender_age, 'NULL')::NUMERIC),2) AS offender_age_avg,
		ROUND(AVG(NULLIF(offender_number, 'NULL')::NUMERIC),2) AS offender_number_avg
	FROM _police_reports_2010_2025
	GROUP BY EXTRACT(YEAR FROM occurred_date_time), district
	ORDER BY EXTRACT(YEAR FROM occurred_date_time), district
),
most_repeated_victim_race AS (
	SELECT 
		reported_year,
		district,
		victim_race
	FROM (
		SELECT 
			EXTRACT(YEAR FROM occurred_date_time) AS reported_year, district,
			victim_race,
			COUNT(victim_race),
			ROW_NUMBER() OVER (
				PARTITION BY EXTRACT(YEAR FROM occurred_date_time), district
				ORDER BY COUNT(victim_race) DESC
			) AS rn
		FROM _police_reports_2010_2025
		WHERE victim_race != 'NULL'
		GROUP BY EXTRACT(YEAR FROM occurred_date_time), district, victim_race
	)
	WHERE rn = 1
	ORDER BY reported_year, district
),
most_repeated_victim_gender AS (
	SELECT 
		reported_year,
		district,
		victim_gender
	FROM (
		SELECT 
			EXTRACT(YEAR FROM occurred_date_time) AS reported_year, district,
			victim_gender,
			COUNT(victim_gender),
			ROW_NUMBER() OVER (
				PARTITION BY EXTRACT(YEAR FROM occurred_date_time), district
				ORDER BY COUNT(victim_gender) DESC
			) AS rn
		FROM _police_reports_2010_2025
		WHERE victim_gender != 'NULL'
		GROUP BY EXTRACT(YEAR FROM occurred_date_time), district, victim_gender
	)
	WHERE rn = 1
	ORDER BY reported_year, district
),
victim_avg AS (
	SELECT 
		EXTRACT(YEAR FROM occurred_date_time) AS reported_year,
		district,
		ROUND(AVG(NULLIF(victim_age, 'NULL')::NUMERIC),2) AS victim_age_avg,
		ROUND(AVG(NULLIF(victim_number, 'NULL')::NUMERIC),2) AS victim_number_avg
	FROM _police_reports_2010_2025
	GROUP BY EXTRACT(YEAR FROM occurred_date_time), district
	ORDER BY EXTRACT(YEAR FROM occurred_date_time), district
),
fatal_status_ratio AS (
	SELECT 
		EXTRACT(YEAR FROM occurred_date_time) AS reported_year,
		district,
		COUNT(DISTINCT item_number) FILTER (WHERE victim_fatal_status = 'Fatal')::NUMERIC
			/ NULLIF(COUNT(DISTINCT item_number),0) AS fatal_ratio
	FROM _police_reports_2010_2025
	GROUP BY EXTRACT(YEAR FROM occurred_date_time), district
	ORDER BY reported_year, district
),
yoy_closed AS (
	 SELECT
        reported_year,
        district,
        closed_cases 
            - LAG(closed_cases) OVER (
                PARTITION BY district
                ORDER BY reported_year
            ) AS yoy_closed_cases
    FROM disposition_ratio
    ORDER BY reported_year, district
)

SELECT 
	yd.*,
	dr.count_cases,
	dr.closed_cases,
	mrsd.signal_description,
	mror.offender_race,
	mrog.offender_gender,
	oavg.offender_age_avg,
	oavg.offender_number_avg,
	mrvr.victim_race,
	mrvg.victim_gender,
	vavg.victim_age_avg,
	vavg.victim_number_avg,
	fsr.fatal_ratio,
	yoy.yoy_closed_cases
FROM year_district yd
JOIN disposition_ratio dr
	ON yd.reported_year = dr.reported_year
		AND yd.district = dr.district
JOIN most_repeated_signal_description mrsd
	ON yd.reported_year = mrsd.reported_year
		AND yd.district = mrsd.district
JOIN most_repeated_offender_race mror
	ON yd.reported_year = mror.reported_year
		AND yd.district = mror.district
JOIN most_repeated_offender_gender mrog
	ON yd.reported_year = mrog.reported_year
		AND yd.district = mrog.district
JOIN offender_avg oavg
	ON yd.reported_year = oavg.reported_year
		AND yd.district = oavg.district
JOIN most_repeated_victim_race mrvr
	ON yd.reported_year = mrvr.reported_year
		AND yd.district = mrvr.district
JOIN most_repeated_victim_gender mrvg
	ON yd.reported_year = mrvg.reported_year
		AND yd.district = mrvg.district
JOIN victim_avg vavg
	ON yd.reported_year = vavg.reported_year
		AND yd.district = vavg.district
JOIN fatal_status_ratio fsr
	ON yd.reported_year = fsr.reported_year
		AND yd.district = fsr.district
JOIN yoy_closed yoy
	ON yd.reported_year = yoy.reported_year
		AND yd.district = yoy.district




