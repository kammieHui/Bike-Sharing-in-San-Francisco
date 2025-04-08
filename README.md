# Bike-Sharing-in-San-Francisco
SQL + Power BI Project to uncover the trends in usage,  of share bikes

## 📌 Objective  
Analyze San Francisco Bike Sharing public data to uncover trends in subscription, popular routes, ride duration.  
Provide insights to improve service quality and hardware efficiency.

## 🗂️ Dataset  
The dataset was a public data from bigquery, 3 datasets has been used in this project<br>
- <b>Bikeshare_trips:- </b><br>
  data size: 891K rows x 11 columns <br>
  Key Columns<br>
  <code> trip_id:</code> Numeric ID of bike trip <br>
  <code> duration_sec:</code> Time of trip in seconds<br>
  <code> start_date:</code> Start date of trip with data and time, in PST<br>
  <code> start_station_name:</code> Station name of Start Station<br>
  <code> end_date:</code> Numeric Reference of Start Station<br>
  <code> end_station_name:</code> End date of trip with data and time, in PST<br>
  <code> end_station_id:</code> Numeric Reference of End Station<br>
  <code> bike_number:</code> ID of bike used<br>
  <code> subscriber_type:</code> Subscriber = Annual Or 30 day member; Customer = 24-hour or 3-day member<br>
  <br>
- <b>Bikeshare_status:-</b> <br>
  Record createdwhen a bike bing pick up or return.<br>
  data size: 107501K rows x 4 columns<br>
  Key Columns used<br>
  <code>station_id:</code>Station ID number<br>
  <code>bikes_available:</code>Number of available bikes<br>
  <code>docks_available:</code>Number of available docks<br>
  <code>time:</code>Date and time, PST<br>
  <br>  
- <b>Bikeshare_stations:- </b><br>
  Record bike stations installation date, locations, and bikes and dock installed<br>
  data size: 74 rows x 7 columns<br>
  Key columns<br>
  <code>station_id:</code> Station ID number<br>
  <code>name:</code> Name of station<br>
  <code>latitude:</code> Latitude<br>
  <code>longitdue:</code> Longitude<br>
  <code>dockcount:</code> Number of total docks at stations<br>
  <code>landmark:</code> City ( San Francisco, Redwood, City, Palo Alto, Mountain View, San Jose)<br>
  <code>installation_date:</code> Original date that station was installed. <br>

## 🔧 Data Cleaning & Preparation  
- Cleaned and formatted data in BigQuery
- Removed null values, fixed data types, deduplicated rows
  
## 🧠 Key SQL Queries (BigQuery)

- <b>only Trips in San Francisco are relevant to this project</b>
```sql
SELECT * 
FROM `bigquery-public-data.san_francisco.bikeshare_trips` AS trips
JOIN `bigquery-public-data.san_francisco.bikeshare_stations` AS stations
ON trips.start_station_id = stations.station_id
WHERE stations.landmark = 'San Francisco'
```
- <b>Find out the most popular route in San Francisco among subscriber and customer</b><br>
```sql
WITH SF_trips AS (
  SELECT * 
  FROM `bigquery-public-data.san_francisco.bikeshare_trips` as trips
  JOIN `bigquery-public-data.san_francisco.bikeshare_stations` as stations
  ON trips.start_station_id = stations.station_id
  WHERE stations.landmark = 'San Francisco'

)
SELECT
   start_station_name,
   end_station_name,
   COUNT(*) AS trip_count,
   SUM(
    CASE 
      WHEN subscriber_type = 'Customer'  
      THEN 1
      ELSE 0
    END) AS Customer_Count,
    SUM(
    CASE 
      WHEN subscriber_type = 'Subscriber' 
      THEN 1
      ELSE 0
    END) AS Subscriber_Count
FROM SF_trips
GROUP BY 
  start_station_name,
  end_station_name
ORDERY BY
  trip_count DESC
```
- <b>Find out most popular riding duration</b><br>
```sql
WITH SF_trips AS (
  SELECT * 
  FROM `bigquery-public-data.san_francisco.bikeshare_trips` as trips
  JOIN `bigquery-public-data.san_francisco.bikeshare_stations` as stations
  ON trips.start_station_id = stations.station_id
  WHERE stations.landmark = 'San Francisco'

)
SELECT
  CASE 
    WHEN ROUND((duration_sec/60), 0) <= 5 THEN 'Short (<5 min)'
    WHEN ROUND((duration_sec/60), 0) BETWEEN 6 AND 20 THEN 'Medium (5-20 min)'
    WHEN ROUND((duration_sec/60), 0) BETWEEN 21 AND 60 THEN 'Long (20-60 min)'
    ELSE 'Very Long (>60 min)'
  END AS duration_category,
  COUNT(*) AS no_of_cat,
  SUM(CASE 
    WHEN subscriber_type = 'Customer' THEN 1 ELSE 0 
  END) AS total_customer,
  SUM(CASE 
    WHEN subscriber_type = 'Subscriber' THEN 1 ELSE 0 
  END) AS total_subscriber
FROM SF_trips
GROUP BY 
  duration_category
ORDER BY no_of_cat DESC;
```

- <b>Find out houly bikes availability on each stations</b><br>
```sql
WITH average_hour_availability AS ( 
  SELECT 
    station_id, 
    EXTRACT(HOUR FROM time) AS hour, 
    EXTRACT(DAYOFWEEK FROM time) AS day_of_week, -- Extracts day of the week (1 = Sunday, 7 = Saturday)
    ROUND(AVG(bikes_available),2) AS avg_bikes_available, 
    ROUND(AVG(docks_available),2) AS avg_docks_available
  FROM `bigquery-public-data.san_francisco.bikeshare_status` 
  GROUP BY station_id, hour, day_of_week
) 

SELECT
  a.station_id,
  s.name, 
  a.hour, 
  a.day_of_week,  
  a.avg_bikes_available, 
  a.avg_docks_available, 
  ROUND((a.avg_bikes_available - a.avg_docks_available), 2) AS difference_avail
FROM average_hour_availability AS a
JOIN `bigquery-public-data.san_francisco.bikeshare_stations` AS s
ON a.station_id = s.station_id
WHERE s.landmark = 'San Francisco'
ORDER BY 
  a.station_id,
  s.name, 
  a.day_of_week,  
  a.hour, 
  a.avg_bikes_available, 
  a.avg_docks_available;
```

## 📈 Power BI Report  
Report includes:-<br>
- <b>Cards</b> - Overview of total rides, number of stations, and active bikes 
- <b>Tables</b> - Popular Routes, top start stations and underused stations
- <b>Stacked Bar Charts</b> - Ride duration preference, ride growth, bike usuage longevity
- <b>Line Charts with Slicer</b> - Hourly bikes availability across different stations and days of the week

## 💡 Key Insights
- Some of the Station are significantly underused compared to others.
- Most Popular Ride duration is around 5 - 20 mins.
- Annual/30-day subscribers account for the majority of rides — 7 to 8 times more than 24–72 hour users.
- Around half of the bikes are heavily underutilized compared to the other half. Some individual bikes are heavily used. Further investigation may help optimize bike distribution and increase lifespan.
- Peak bike availability hours vary across stations. While no clear pattern is concluded, observing station-level trends may support more strategic resource planning.

## 📎 Files Included
- `queries.sql`: SQL scripts used in BigQuery
- [`Report/PowerBI_SF_share bikes_v.1.1.pdf`](./Report/PowerBI_SF_share%20bikes_v.1.1.pdf): Exported Power BI Report
- `README.md`: This project summary

## 📚 Learnings
- More hands-on practice with SQL using BigQuery, especially with JOINs, CTEs, and window functions
- Learned how to clean and prepare data for analysis (e.g. fixing formats, removing duplicates, filtering relevant rows)
- connected BigQuery to Power BI and worked through setting up the data model
- Built a Power BI dashboard using cards, tables, bar and line charts, and slicers
- Practiced visualizing data to highlight trends and make the report easier to understand
- Learned how to document the project clearly in a structured GitHub README
