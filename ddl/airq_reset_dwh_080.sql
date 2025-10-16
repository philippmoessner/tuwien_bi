-- -------------------------------
-- 1) Assignment 1: create/reset dwh_xxx schema per group
-- -------------------------------
DROP SCHEMA IF EXISTS dwh_080 CASCADE;
CREATE SCHEMA dwh_080 AUTHORIZATION grp_080;