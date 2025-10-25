-- Make A1 dwh_xxx schema the default for this session
SET search_path TO dwh_080;

-- -------------------------------
-- 2) DROP TABLE before attempting to create DWH schema tables
-- -------------------------------
DROP TABLE IF EXISTS dim_timeday;
DROP TABLE IF EXISTS dim_servicetype;
DROP TABLE IF EXISTS dim_employee;
DROP TABLE IF EXISTS dim_city;
DROP TABLE IF EXISTS dim_device;
DROP TABLE IF EXISTS dim_param;
DROP TABLE IF EXISTS dim_weather_extremeness;
DROP TABLE IF EXISTS ft_serviceevent;
DROP TABLE IF EXISTS ft_readingevent;


-- -------------------------------
-- 3) CREATE TABLE statements for facts and dimensions
-- Please make sure the order in which individual statements are executed respects the FOREIGN KEY constraints
-- -------------------------------

----------------------
-- DIMENSION TABLES --
----------------------

CREATE TABLE dim_timeday (
    id INT NOT NULL PRIMARY KEY
    full_date DATE NOT NULL UNIQUE,
    day_of_month INT NOT NULL,
    month_num INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    year_num INT NOT NULL,
    week_num INT NOT NULL,
    day_of_week_num INT NOT NULL,
    day_of_week_name VARCHAR(15) NOT NULL,
    etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dim_servicetype (
    servicetype_key BIGSERIAL PRIMARY KEY,
    servicetype_id INT NOT NULL UNIQUE,
    typename VARCHAR(255) NOT NULL,
    servicegroup VARCHAR(255) NOT NULL,
    category VARCHAR(255) NOT NULL,
    minlevel INT NOT NULL,
    details VARCHAR(255) NOT NULL,
    etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dim_employee (
    employee_key BIGSERIAL PRIMARY KEY,
    badgenumber VARCHAR(255) NOT NULL,
    rolename VARCHAR(255) NOT NULL,
    rolelevel INT NOT NULL,
    category VARCHAR(255) NOT NULL,
    valid_from DATE NOT NULL,
    valid_to DATE NULL,
    is_active BOOLEAN NOT NULL,
    months_of_education INT NULL,
    etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dim_city (
    city_key BIGSERIAL PRIMARY KEY,
    city_id INT NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    population INT NOT NULL,
    latitude DECIMAL(10,4) NOT NULL,
    longitude DECIMAL(10,4) NOT NULL,
    etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dim_device (
    device_key BIGSERIAL PRIMARY KEY,
    device_id INT NOT NULL UNIQUE,
    sensortype VARCHAR(255) NOT NULL,
    manufacturer VARCHAR(255) NOT NULL,
    technology VARCHAR(255) NOT NULL,
    locationname VARCHAR(255) NOT NULL,
    locationtype VARCHAR(255) NOT NULL,
    altitude INT NOT NULL,
    installdate DATE NOT NULL,
    city VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dim_param (
    param_key BIGSERIAL PRIMARY KEY,
    param_id INT NOT NULL UNIQUE,
    paramname VARCHAR(255) NOT NULL,
    category VARCHAR(255) NOT NULL,
    purpose VARCHAR(50) NOT NULL,
    unit VARCHAR(255) NOT NULL,
    etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dim_weather_extremeness (
    weather_extremeness_key BIGSERIAL PRIMARY KEY,
    extremeness_level VARCHAR(64) NOT NULL,
    etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-----------------
-- FACT TABLES --
-----------------

CREATE TABLE ft_serviceevent (
    id BIGSERIAL PRIMARY KEY,
    
    -- FOREIGN KEY TO DIM TABLES
    timeday_key INT NOT NULL,
    servicetype_key INT NOT NULL,
    employee_key BIGINT NOT NULL,
    city_key INT NOT NULL,
    device_key INT NOT NULL,

    -- MEASURES
    service_cost INT NOT NULL,
    service_duration_minutes INT NOT NULL,
    service_quality INT NOT NULL,
    qualified_work INT NOT NULL,
    overqualified_work INT NOT NULL,

    etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_ft_serviceevent_timeday FOREIGN KEY (timeday_key) REFERENCES dim_timeday(timeday_key),
    CONSTRAINT fk_ft_serviceevent_servicetype FOREIGN KEY (servicetype_key) REFERENCES dim_servicetype(servicetype_key),
    CONSTRAINT fk_ft_serviceevent_employee FOREIGN KEY (employee_key) REFERENCES dim_employee(employee_key),
    CONSTRAINT fk_ft_serviceevent_city FOREIGN KEY (city_key) REFERENCES dim_city(city_key),
    CONSTRAINT fk_ft_serviceevent_device FOREIGN KEY (device_key) REFERENCES dim_device(device_key)
);

CREATE TABLE ft_readingevent (
    id BIGSERIAL PRIMARY KEY,

    -- FOREIGN KEY TO DIM TABLES
    timeday_key INT NOT NULL,
    city_key INT NOT NULL,
    device_key INT NOT NULL,
    param_key INT NOT NULL,
    weather_extremeness_key INT NOT NULL,

    -- MEASURES
    event_count INT NOT NULL DEFAULT 1,
    recordedvalue DECIMAL(10,4) NOT NULL,
    datavolumekb INT NOT NULL,
    dataquality INT NOT NULL,
    alertlevel INT NOT NULL,

    etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_ft_readingevent_timeday FOREIGN KEY (timeday_key) REFERENCES dim_timeday(timeday_key),
    CONSTRAINT fk_ft_readingevent_city FOREIGN KEY (city_key) REFERENCES dim_city(city_key),
    CONSTRAINT fk_ft_readingevent_device FOREIGN KEY (device_key) REFERENCES dim_device(device_key),
    CONSTRAINT fk_ft_readingevent_param FOREIGN KEY (param_key) REFERENCES dim_param(param_key),
    CONSTRAINT fk_ft_readingevent_weather FOREIGN KEY (weather_extremeness_key) REFERENCES dim_weather_extremeness(weather_extremeness_key)
);
