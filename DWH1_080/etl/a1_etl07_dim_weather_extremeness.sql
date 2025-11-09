SET search_path TO dwh_080;

TRUNCATE TABLE dim_weather_extremeness RESTART IDENTITY CASCADE;

INSERT INTO dim_weather_extremeness (extremeness_flag)
VALUES
    ('Normal'),
    ('Heatwave'),
    ('ColdSnap'),
    ('HeavyRain'),
    ('HighWind')
ON CONFLICT (extremeness_flag) DO NOTHING;

-- [ADDED] Analyze for statistics
ANALYZE dim_weather_extremeness;