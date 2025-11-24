--- Insert into the fact table police report
INSERT INTO police_reports
SELECT
	item_number,
	district,
	occurred_date_time::DATE AS report_date,
	disposition,
	charge_code,
	charge_description,
	COUNT(DISTINCT victim_number) AS total_victim_number,
	COUNT(DISTINCT offender_number) AS total_offender_number	
FROM police_reports_2010_2019
GROUP BY item_number, district, report_date, disposition, charge_code, charge_description

UNION ALL

SELECT
	item_number,
	district,
	occurred_date_time::DATE AS report_date,
	disposition,
	charge_code,
	charge_description,
	COUNT(DISTINCT victim_number) AS total_victim_number,
	COUNT(DISTINCT offender_number) AS total_offender_number	
FROM police_reports_2020
GROUP BY item_number, district, report_date, disposition, charge_code, charge_description
ORDER BY report_date;


SELECT
	charge_code,
	COUNT(*)
FROM police_reports
GROUP BY charge_code

SELECT *
FROM police_reports
limit 5;