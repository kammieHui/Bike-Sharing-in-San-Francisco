

WITH SF_trips AS 
(
  SELECT * 
  FROM `bigquery-public-data.san_francisco.bikeshare_trips` AS trips
  JOIN `bigquery-public-data.san_francisco.bikeshare_stations` AS stations
  ON trips.start_station_id = stations.station_id
  WHERE stations.landmark = 'San Francisco'   -- only San Francisco Data matters
)
  SELECT 
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    COUNT(trip_id) AS trip_count, -- each route count 
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
    END) AS Subscriber_Count -- try to observe if any particluar route is more popular by certain groups
  FROM SF_trips
  
  GROUP BY 
  start_station_name,start_station_id, end_station_name,end_station_id
  ORDER BY trip_count DESC