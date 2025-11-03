SET search_path TO dwh_080, stg_080;

TRUNCATE TABLE dim_power_plan RESTART IDENTITY CASCADE;

INSERT INTO dwh_080.dim_power_plan (
    power_plan_nk,
    provider,
    plan_name,
    tier,
    price_index,
    notes
)

SELECT
    p.id AS power_plan_nk,
    p.provider,
    p.plan_name,
    p.tier,
    p.price_index,
    p.notes
FROM stg_080.tb_power_plan p;

ANALYZE dim_power_plan;