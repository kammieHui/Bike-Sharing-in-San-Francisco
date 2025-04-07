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

```sql
-- only Trips in San Francisco are relevant to this project
SELECT * 
FROM `bigquery-public-data.san_francisco.bikeshare_trips` AS trips
JOIN `bigquery-public-data.san_francisco.bikeshare_stations` AS stations
ON trips.start_station_id = stations.station_id
WHERE stations.landmark = 'San Francisco'
```
- Find out the most popular route in San Francisco among subscriber and customer<br>
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
- Find out most popular riding duration<br>
```sql
WITH duration AS (
  SELECT
    ROUND((duration_sec/60), 0) AS mins,
    subscriber_type
  FROM `bigquery-public-data.san_francisco.bikeshare_trips`
  ORDER BY mins
) 
SELECT 
  CASE 
    WHEN duration.mins <= 5 THEN 'Short (<5 min)'
    WHEN duration.mins BETWEEN 6 AND 20 THEN 'Medium (5-20 min)'
    WHEN duration.mins BETWEEN 21 AND 60 THEN 'Long (20-60 min)'
    ELSE 'Very Long (>60 min)'
  END AS duration_category,
  COUNT(*) as no_of_cat,
  SUM(CASE 
    WHEN subscriber_type = 'Customer' 
      THEN 1
      ELSE 0
    END) AS total_customer,
  SUM(CASE
    WHEN subscriber_type = 'Subscriber'
      THEN 1
      ELSE 0
    END) AS total_subscriber
FROM duration
GROUP BY duration_category
```

## 📈 Power BI Dashboard  
- Built interactive visuals: bar charts, slicers, and KPIs
- Added filters for date range, agent name, and satisfaction score
- Summary KPIs: Avg Response Time, % Satisfied Customers, Volume by Channel

## 💡 Key Insights
- Response time is highest during weekends.
- Agent X consistently outperforms others in customer satisfaction.
- Chat support has higher resolution rate than email.

## 📎 Files Included
- `queries.sql`: SQL scripts used in BigQuery
- `Customer_Service_Report.pdf`: Power BI dashboard export
- `README.md`: This project summary

## 📚 Learnings
- Practiced window functions and CTEs in BigQuery
- Learned to connect BigQuery to Power BI
- Improved dashboard storytelling using filters and KPIs
