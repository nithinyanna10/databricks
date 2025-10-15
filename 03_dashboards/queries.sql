-- Databricks SQL Queries for Dashboard Creation
-- These queries demonstrate various analytical patterns for business intelligence

-- 1. Flight Count by Carrier
SELECT 
    carrier,
    COUNT(*) AS flight_count
FROM airlines_delta 
GROUP BY carrier 
ORDER BY flight_count DESC
LIMIT 10;

-- 2. Average Delay by Carrier
SELECT 
    carrier,
    AVG(dep_delay) AS avg_departure_delay,
    AVG(arr_delay) AS avg_arrival_delay
FROM airlines_delta 
WHERE dep_delay IS NOT NULL AND arr_delay IS NOT NULL
GROUP BY carrier 
ORDER BY avg_departure_delay DESC
LIMIT 10;

-- 3. Monthly Flight Trends
SELECT 
    YEAR(date) AS year,
    MONTH(date) AS month,
    COUNT(*) AS total_flights
FROM airlines_delta 
GROUP BY YEAR(date), MONTH(date)
ORDER BY year, month;

-- 4. Top Routes by Flight Count
SELECT 
    origin,
    dest,
    COUNT(*) AS route_count
FROM airlines_delta 
GROUP BY origin, dest
ORDER BY route_count DESC
LIMIT 20;

-- 5. Delay Analysis by Time of Day
SELECT 
    CASE 
        WHEN hour BETWEEN 6 AND 11 THEN 'Morning (6-11)'
        WHEN hour BETWEEN 12 AND 17 THEN 'Afternoon (12-17)'
        WHEN hour BETWEEN 18 AND 23 THEN 'Evening (18-23)'
        ELSE 'Night (0-5)'
    END AS time_period,
    AVG(dep_delay) AS avg_delay,
    COUNT(*) AS flight_count
FROM airlines_delta 
WHERE dep_delay IS NOT NULL
GROUP BY 
    CASE 
        WHEN hour BETWEEN 6 AND 11 THEN 'Morning (6-11)'
        WHEN hour BETWEEN 12 AND 17 THEN 'Afternoon (12-17)'
        WHEN hour BETWEEN 18 AND 23 THEN 'Evening (18-23)'
        ELSE 'Night (0-5)'
    END
ORDER BY avg_delay DESC;

-- 6. Cancellation Rate by Carrier
SELECT 
    carrier,
    COUNT(*) AS total_flights,
    SUM(CASE WHEN cancelled = 1 THEN 1 ELSE 0 END) AS cancelled_flights,
    ROUND(
        (SUM(CASE WHEN cancelled = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2
    ) AS cancellation_rate
FROM airlines_delta 
GROUP BY carrier 
HAVING COUNT(*) > 1000  -- Only carriers with significant volume
ORDER BY cancellation_rate DESC;

-- 7. Seasonal Delay Patterns
SELECT 
    CASE 
        WHEN MONTH(date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(date) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
    END AS season,
    AVG(dep_delay) AS avg_departure_delay,
    AVG(arr_delay) AS avg_arrival_delay,
    COUNT(*) AS total_flights
FROM airlines_delta 
WHERE dep_delay IS NOT NULL AND arr_delay IS NOT NULL
GROUP BY 
    CASE 
        WHEN MONTH(date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(date) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
    END
ORDER BY avg_departure_delay DESC;

-- 8. Airport Performance Metrics
SELECT 
    origin AS airport,
    COUNT(*) AS total_departures,
    AVG(dep_delay) AS avg_departure_delay,
    SUM(CASE WHEN dep_delay > 0 THEN 1 ELSE 0 END) AS delayed_departures,
    ROUND(
        (SUM(CASE WHEN dep_delay > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2
    ) AS delay_percentage
FROM airlines_delta 
WHERE dep_delay IS NOT NULL
GROUP BY origin
HAVING COUNT(*) > 5000  -- Only major airports
ORDER BY delay_percentage DESC
LIMIT 20;
