-- to find out preferred riding duration among all San Francisco Trips Record

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
  END AS duration_category, -- Use CASE to set 4 bins 
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