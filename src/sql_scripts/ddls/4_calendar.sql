CREATE TABLE calendar (
    dt date PRIMARY KEY,
    year int,
    month int,
    day int,
    day_of_week int,      -- 1=Monday, 7=Sunday
    week int
);

INSERT INTO calendar (dt, year, month, day, day_of_week, week)
SELECT
    d,
    EXTRACT(year FROM d)::int,
    EXTRACT(month FROM d)::int,
    EXTRACT(day FROM d)::int,
    EXTRACT(isodow FROM d)::int,
    EXTRACT(week FROM d)::int
FROM generate_series(
    '2010-01-01'::date,
    '2030-12-31'::date,
    '1 day'::interval
) AS d;

SELECT *
FROM calendar;

