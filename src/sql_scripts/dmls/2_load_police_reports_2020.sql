COPY police_reports_2020
FROM 'D:\Enrique\Portfolio\City of New Orleands\data\raw_data\police reports\Electronic_Police_Report_2025_20251115.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');