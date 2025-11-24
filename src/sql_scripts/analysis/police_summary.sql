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
CREATE TABLE IF NOT EXISTS police_summary (
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
INSERT INTO police_summary
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
most_reported_district AS (
	SELECT 
	    reported_year,
	    district    
	FROM (
	    SELECT 
	        EXTRACT(YEAR FROM occurred_date_time) AS reported_year,
	        district,
	        ROW_NUMBER() OVER (
	            PARTITION BY EXTRACT(YEAR FROM occurred_date_time)
	            ORDER BY COUNT(DISTINCT item_number) DESC
	        ) AS rn
	    FROM _police_reports_2010_2025
	    GROUP BY EXTRACT(YEAR FROM occurred_date_time), district
	) t
	WHERE rn = 1
),
disposition_ratio AS (
	SELECT
		EXTRACT(YEAR FROM occurred_date_time) AS reported_year,
		COUNT(DISTINCT item_number) AS count_cases,
		COUNT(DISTINCT item_number) FILTER (WHERE disposition = 'CLOSED')::numeric AS closed_cases
	FROM _police_reports_2010_2025
	GROUP BY EXTRACT(YEAR FROM occurred_date_time)
),
most_repeated_signal_description AS (
	SELECT 
		reported_year,
		signal_description
	FROM (
		SELECT 
			EXTRACT(YEAR FROM occurred_date_time) AS reported_year,
			signal_description,
			COUNT(signal_description),
			ROW_NUMBER() OVER (
				PARTITION BY EXTRACT(YEAR FROM occurred_date_time)
				ORDER BY COUNT(signal_description) DESC
			) AS rn
		FROM _police_reports_2010_2025
		GROUP BY EXTRACT(YEAR FROM occurred_date_time), signal_description
	)
	WHERE rn = 1
),
most_repeated_offender_race AS (
	SELECT 
		reported_year,
		offender_race
	FROM (
		SELECT 
			EXTRACT(YEAR FROM occurred_date_time) AS reported_year,
			offender_race,
			COUNT(offender_race),
			ROW_NUMBER() OVER (
				PARTITION BY EXTRACT(YEAR FROM occurred_date_time)
				ORDER BY COUNT(offender_race) DESC
			) AS rn
		FROM _police_reports_2010_2025
		WHERE offender_race != 'NULL'
		GROUP BY EXTRACT(YEAR FROM occurred_date_time), offender_race
	)
	WHERE rn = 1
),
most_repeated_offender_gender AS (
	SELECT 
		reported_year,
		offender_gender
	FROM (
		SELECT 
			EXTRACT(YEAR FROM occurred_date_time) AS reported_year,
			offender_gender,
			COUNT(offender_gender),
			ROW_NUMBER() OVER (
				PARTITION BY EXTRACT(YEAR FROM occurred_date_time)
				ORDER BY COUNT(offender_gender) DESC
			) AS rn
		FROM _police_reports_2010_2025
		WHERE offender_gender != 'NULL'
		GROUP BY EXTRACT(YEAR FROM occurred_date_time), offender_gender
	)
	WHERE rn = 1
),
offender_avg AS (
	SELECT 
		EXTRACT(YEAR FROM occurred_date_time) AS reported_year,
		ROUND(AVG(NULLIF(offender_age, 'NULL')::NUMERIC),2) AS offender_age_avg,
		ROUND(AVG(NULLIF(offender_number, 'NULL')::NUMERIC),2) AS offender_number_avg
	FROM _police_reports_2010_2025
	GROUP BY EXTRACT(YEAR FROM occurred_date_time)
),
most_repeated_victim_race AS (
	SELECT 
		reported_year,
		victim_race
	FROM (
		SELECT 
			EXTRACT(YEAR FROM occurred_date_time) AS reported_year,
			victim_race,
			COUNT(victim_race),
			ROW_NUMBER() OVER (
				PARTITION BY EXTRACT(YEAR FROM occurred_date_time)
				ORDER BY COUNT(victim_race) DESC
			) AS rn
		FROM _police_reports_2010_2025
		WHERE victim_race != 'NULL'
		GROUP BY EXTRACT(YEAR FROM occurred_date_time), victim_race
	)
	WHERE rn = 1
),
most_repeated_victim_gender AS (
	SELECT 
		reported_year,
		victim_gender
	FROM (
		SELECT 
			EXTRACT(YEAR FROM occurred_date_time) AS reported_year,
			victim_gender,
			COUNT(victim_gender),
			ROW_NUMBER() OVER (
				PARTITION BY EXTRACT(YEAR FROM occurred_date_time)
				ORDER BY COUNT(victim_gender) DESC
			) AS rn
		FROM _police_reports_2010_2025
		WHERE victim_gender != 'NULL'
		GROUP BY EXTRACT(YEAR FROM occurred_date_time), victim_gender
	)
	WHERE rn = 1
),
victim_avg AS (
	SELECT 
		EXTRACT(YEAR FROM occurred_date_time) AS reported_year,
		ROUND(AVG(NULLIF(victim_age, 'NULL')::NUMERIC),2) AS victim_age_avg,
		ROUND(AVG(NULLIF(victim_number, 'NULL')::NUMERIC),2) AS victim_number_avg
	FROM _police_reports_2010_2025
	GROUP BY EXTRACT(YEAR FROM occurred_date_time)
),
fatal_status_ratio AS (
	SELECT 
		EXTRACT(YEAR FROM occurred_date_time) AS reported_year,
		COUNT(DISTINCT item_number) FILTER (WHERE victim_fatal_status = 'Fatal')::NUMERIC
			/ NULLIF(COUNT(DISTINCT item_number),0) AS fatal_ratio
	FROM _police_reports_2010_2025
	GROUP BY EXTRACT(YEAR FROM occurred_date_time)
),
yoy_closed AS (
	SELECT
        reported_year,
        closed_cases - LAG(closed_cases, 1) OVER (ORDER BY reported_year) AS yoy_closed_cases
    FROM disposition_ratio
)

SELECT 
	mrd.*,
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
FROM most_reported_district mrd
JOIN disposition_ratio dr
	ON mrd.reported_year = dr.reported_year
JOIN most_repeated_signal_description mrsd
	ON mrd.reported_year = mrsd.reported_year
JOIN most_repeated_offender_race mror
	ON mrd.reported_year = mror.reported_year
JOIN most_repeated_offender_gender mrog
	ON mrd.reported_year = mrog.reported_year
JOIN offender_avg oavg
	ON mrd.reported_year = oavg.reported_year
JOIN most_repeated_victim_race mrvr
	ON mrd.reported_year = mrvr.reported_year
JOIN most_repeated_victim_gender mrvg
	ON mrd.reported_year = mrvg.reported_year
JOIN victim_avg vavg
	ON mrd.reported_year = vavg.reported_year
JOIN fatal_status_ratio fsr
	ON mrd.reported_year = fsr.reported_year
JOIN yoy_closed yoy
	ON mrd.reported_year = yoy.reported_year




