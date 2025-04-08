WITH SF_trips AS (
  SELECT * 
  FROM `bigquery-public-data.san_francisco.bikeshare_trips` as trips
  JOIN `bigquery-public-data.san_francisco.bikeshare_stations` as stations
  ON trips.start_station_id = stations.station_id
  WHERE stations.landmark = 'San Francisco'

)
SELECT
  bike_number,
  COUNT(*) AS number_of_use
FROM SF_trips
GROUP BY bike_number
ORDER BY number_of_use DESC 

-- to have a list of bike ID and number of use for further investigation