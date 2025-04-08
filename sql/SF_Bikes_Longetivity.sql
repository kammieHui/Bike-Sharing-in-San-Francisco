WITH SF_trips AS (
  SELECT * 
  FROM `bigquery-public-data.san_francisco.bikeshare_trips` as trips
  JOIN `bigquery-public-data.san_francisco.bikeshare_stations` as stations
  ON trips.start_station_id = stations.station_id
  WHERE stations.landmark = 'San Francisco'

)
SELECT
  bike_number,
  ROUND(SUM(duration_sec)/60,0 )AS total_mins_ride, -- base on riding mintes to see the depreciation of the bike
  COUNT(*) AS number_of_trips -- number of trips as a second reference 
FROM SF_trips
GROUP BY bike_number
ORDER BY total_mins_ride DESC 

-- to have a list of bike ID and number of use for further investigation
