COPY police_reports_2010_2019
FROM 'D:\Enrique\Portfolio\City of New Orleands\data\raw_data\police reports\Electronic_Police_Report_2019.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');