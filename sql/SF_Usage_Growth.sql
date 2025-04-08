-- subscriber type only 2 types: subscriber #1 - 12 mth /  customer 12 - 36 hours

--Question: Who uses the service more: Subscribers vs. Casual users form 2013 - 2016?

WITH trips_by_year AS (
  SELECT
    EXTRACT(YEAR FROM start_date) AS year,
    subscriber_type,
    COUNT(trip_id) AS total_trips
  FROM
    `bigquery-public-data.san_francisco.bikeshare_trips` as trips
  JOIN `bigquery-public-data.san_francisco.bikeshare_stations` as stations
  ON trips.start_station_id = stations.station_id
  WHERE stations.landmark = 'San Francisco' AND
  EXTRACT(YEAR FROM start_date) BETWEEN 2013 AND 2016
  GROUP BY
    year, subscriber_type
)

SELECT
  year,
  subscriber_type,
  total_trips,
  COALESCE(total_trips - LAG(total_trips) OVER (PARTITION BY subscriber_type ORDER BY year), 0) AS difference_from_last_year, 
  -- consider the first year will return null on "difference_from_last_year", need to handle by coalesce as 0
  CASE
    WHEN LAG(total_trips) OVER (PARTITION BY subscriber_type ORDER BY year) = 0 THEN 0
    ELSE ROUND(((total_trips - LAG(total_trips) OVER (PARTITION BY subscriber_type ORDER BY year)) / LAG(total_trips) OVER (PARTITION BY subscriber_type ORDER BY year)) * 100, 2)
  END AS percentage_change_from_last_year
FROM
  trips_by_year
ORDER BY
  year, subscriber_type;
