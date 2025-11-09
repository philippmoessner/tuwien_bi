-- please remember to give a meaningful name to both Table X (instead of tb_x) and TableY (instead of tb_y)

-- Make the A1's stg_xxx schema the default for this session
SET search_path TO stg_080;

-- -------------------------------
-- 2) DROP TABLE before attempting to create OLTP snapshot tables
-- -------------------------------
DROP TABLE IF EXISTS tb_certificates;
DROP TABLE IF EXISTS tb_roletocertificate;
DROP TABLE IF EXISTS tb_power_plan;
DROP TABLE IF EXISTS tb_device_power_plan;

CREATE TABLE tb_certificates (
    id VARCHAR(255) NOT NULL PRIMARY KEY
    , type VARCHAR(255) NOT NULL
    , months_of_education INT NOT NULL
);

CREATE TABLE tb_roletocertificate (
    role_id INT NOT NULL
    , certificate_id VARCHAR(255) NOT NULL
    , PRIMARY KEY (role_id, certificate_id)
    , CONSTRAINT fk_roleToCertificates_role FOREIGN KEY (role_id) REFERENCES tb_role(id)
    , CONSTRAINT fk_roleToCertificates_certificate FOREIGN KEY (certificate_id) REFERENCES tb_certificates(id)
);

CREATE TABLE tb_power_plan (
    id INT PRIMARY KEY,                        
    provider    VARCHAR(255) NOT NULL,         
    plan_name   VARCHAR(255) NOT NULL,         
    tier        VARCHAR(50)  NOT NULL,         
    price_index DECIMAL(6,3) NOT NULL,         
    notes       VARCHAR(255)                   
);

CREATE TABLE tb_device_power_plan (
    id              SERIAL PRIMARY KEY,
    sensordevid     INT NOT NULL,              
    power_planid    INT NOT NULL,      
    validfrom       DATE NOT NULL,
    validto         DATE NULL,
    CONSTRAINT fk_device_powerplan_device FOREIGN KEY (sensordevid)
        REFERENCES tb_sensordevice(id),
    CONSTRAINT fk_device_powerplan_plan FOREIGN KEY (power_planid)
        REFERENCES tb_power_plan(id)
);
