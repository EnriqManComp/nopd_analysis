# New Orleans Police Department Data Analysis
## Overview
This project analyzes public police reports from the **New Orleans Open Data Portal**, focusing on trends, patterns, and actionable insights derived from incidents reported by the **New Orleans Police Department (NOPD)**.

The project covers the full data pipeline:
- **Data extraction** from the New Orleans public repository.
- **Data cleaning & transformation** using **Python + SQL**.
- **Insight generation** through custom SQL analytics tables.
- **Interactive reporting** using **Power BI**, including an executive dashboard and district-level dashboards.
- **User-friendly navigation** built into the Power BI report.

## Key Outcomes

- Cleaned and standardized thousands of police incident records
- Produced insight tables through advanced SQL modeling
- Designed an interactive Power BI report with intuitive navigation
- Delivered both executive-level and granular district-level analysis

## Video Demonstration

[Video Demonstration](BI reports/Video Demonstration.gif)


## Data Source

The dataset, includes incident-level information such as:
- Occurred and reported date/time
- Location and district
- Offender and victim demographics
- Case disposition and fatal status
- Offense details

***The dataset is divided in different csv files. You can check them here.***

## Tech Stack

- Python
- SQL (data modeling, insight tables, aggregations)
- Power BI (dashboards, interactivity, navigation)

## Data Cleaning & Transformation

A combined **Python + SQL** pipeline was used to ensure clean, standardized data:

### Python Tasks

- Importing raw NOPD reports from the New Orleans repository.
- Convert District Boundaries from WKT to GeoJSON.
- Standardize District Labels.
- Extract Latitude & Longitude from Geometry.

**Outcome**
These Python transformations produce:
- Clean, normalized district geometries (GeoJSON)
- Accurate district numbers for joins
- Usable latitude/longitude coordinates for station mapping

### SQL Tasks

The SQL tasks focused on building analytical tables and a dimensional model to support Power BI reporting.

**1. District-Level Summary Table**

Created the district_summary table, which contains yearly crime metrics by district, including:

- Total and closed cases
- Most frequent signal description
- Offender and victim demographics
- Average ages and counts
- Fatality ratio
- Year-over-year change in closed cases

This table powers the district dashboards in Power BI.

**2. Citywide (Non-District) Summary Table**

Built the police_summary table, which aggregates the same metrics across the entire city, without a district breakdown.
This dataset supports the executive overview dashboard.

**3. Police Reports Fact Table**

Created the police_reports fact table to support a star schema:

- Report-level grain
- District, disposition, offense details
- Victim/offender counts

This table connects to dimension tables for filtering and analytics.

**4. Calendar Dimension Table**

Added a calendar table with:

- Date
- Year, month, day
- Day of week
- Week number

This calendar dimension is used in Power BI for time-based filtering and trending.

**5. Additional Dimensions**

- District dimension
- Police station locations

Used for filtering, geospatial visualization, and improving the semantic model.

## Power BI Dashboard

The Power BI report consists of two main components:

### Executive Dashboard

A high-level overview of crime trends across New Orleans, featuring:

- Total incidents over time.
- KPI tracking for closed-case performance.
- Incident distribution by district.
- Identification of the district with the most incidents.
- Offender/Victim demographic summaries.
- Disposition analysis.
- Fatal vs. non-fatal incident ratios.

### District-Level Dashboards

Dedicated pages for each police district containing:

- Incident trends over time
- KPI tracking for closed cases
- Top 5 most frequently committed crimes
- Fatality ratio analysis
- Disposition breakdowns
- YoY closed case performance

### Report Navigation

A navigation system allows users to move smoothly between executive and district dashboards