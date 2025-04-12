# 🚲 Bike-Sharing in San Francisco<br>
## SQL + Power BI Project to uncover trends in shared bike usage
---
## 📌 Objective

Analyze San Francisco public bike-sharing data to uncover trends in user types, popular routes, and ride durations.
Provide insights to improve service quality, resource planning, and hardware utilization.

---
## 🗂️ Dataset<br>
Public data from Google BigQuery using 3 datasets:<br>
<br>
**bikeshare_trips**<br>
`891K` rows × `11` columns<br>
Details of each bike trip<br>
<br>
<b>Key columns:</b> <br>
-`trip_id`: Unique ID of bike trip<br>
-`duration_sec`: Trip duration in seconds<br>
-`start_date`, `end_date`: Start and end timestamp (PST)<br>
-`start_station_name`, `end_station_name`: Station names<br>
-`subscriber_type`: Subscriber = 30-day/Annual Member, Customer = 24/72-hour user<br>

**Bikeshare_status** <br>
  `107M` rows x `4` columns<br>
 Real-time data on bike and dock availability<br>
 <br>
  **Key Columns:**<br>
  -`station_id`:Station ID number<br>
  -`bikes_available`:Number of available bikes<br>
  -`docks_available`:Number of available docks<br>
  -`time`:Date and time, PST<br>
  <br>  
**Bikeshare_stations**<br>
 `74` rows x `7` columns<br>
 Station metadata<br>
 
  **Key columns**<br>
  -`station_id`: Station ID <br>
  -`name`: Name of station<br>
  -`latitude`,`longitdue`<br>
  -`dockcount`: Total dock capactiy<br>
  -`landmark`: City ( e.g., San Francisco, Mountain View, San Jose)<br>
  -`installation_date`:  <br>

## 🔧 Data Cleaning & Preparation  
- Cleaned and formatted data in BigQuery
- Filtered only trips within **San Francisco**
  
## 🧠 Key SQL Queries (BigQuery)

1️⃣ Filter Only San Francisco Trips <br>
```sql
SELECT * 
FROM `bigquery-public-data.san_francisco.bikeshare_trips` AS trips
JOIN `bigquery-public-data.san_francisco.bikeshare_stations` AS stations
ON trips.start_station_id = stations.station_id
WHERE stations.landmark = 'San Francisco'
```
2️⃣ Most Popular Routes by User Type<br>
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
3️⃣ Ride Duration Category Analysis<br>
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

4️⃣ Hourly Bike Availability by Station<br>
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
- 🚲 Some stations are heavily underused, indicating a potential for reallocation
-	⏱️ Most popular ride duration is 5–20 minutes
- 👥 Subscribers (30-day/annual) account for 7–8x more rides than short-term customers
- 🔧 Roughly half of the bikes are underutilized, while others are overused
-	⏰ Peak availability hours vary across stations — individualized planning could optimize distribution

## 📎 Files Included
- `queries.sql`: SQL scripts used in BigQuery
- [`Report/PowerBI_SF_share_bikes_v1.2pdf`](./Report/PowerBI_SF_share_bikes_v1.2.pdf): Exported Power BI Report
- `README.md`: This project summary

## 📚 Learnings
-	Practiced advanced SQL in BigQuery: CTEs, joins, aggregation <br>
-	Cleaned and filtered raw data for focused analysis<br>
-	Connected BigQuery to Power BI and built a working data model<br>
-	Designed an interactive dashboard with cards, tables, charts, slicers<br>
- Improved my skills in data storytelling and documentation<br>
