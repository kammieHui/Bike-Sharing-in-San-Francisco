
-- This project choose to get the hourly average availability to observe the usuage pattern

WITH average_hour_availability AS ( 
  SELECT 
    station_id, 
    EXTRACT(HOUR FROM time) AS hour, -- Extract hour part only to simplify the calculation
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