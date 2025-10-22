-- please remember to give a meaningful name to both Table X (instead of tb_x) and TableY (instead of tb_y)

-- Make the A1's stg_xxx schema the default for this session
SET search_path TO stg_080;

-- -------------------------------
-- 2) DROP TABLE before attempting to create OLTP snapshot tables
-- -------------------------------
DROP TABLE IF EXISTS tb_certificates;
DROP TABLE IF EXISTS tb_roletocertificate;

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


