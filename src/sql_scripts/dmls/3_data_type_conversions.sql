--- Data type conversions
ALTER TABLE police_reports_2010_2019
ALTER COLUMN occurred_date_time TYPE TIMESTAMP
USING occurred_date_time::TIMESTAMP; 

SELECT *
FROM police_reports_2010_2019 pr;

ALTER TABLE police_reports_2020
ALTER COLUMN occurred_date_time TYPE TIMESTAMP
USING occurred_date_time::TIMESTAMP; 

SELECT *
FROM police_reports_2020;