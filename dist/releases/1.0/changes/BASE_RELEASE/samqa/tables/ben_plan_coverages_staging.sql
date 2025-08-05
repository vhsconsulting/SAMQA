-- liquibase formatted sql
-- changeset SAMQA:1754374152115 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ben_plan_coverages_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ben_plan_coverages_staging.sql:null:37afa88111aeebeda1d1150c17f053b61803d5e6:create

create table samqa.ben_plan_coverages_staging (
    coverage_id         number,
    ben_plan_id         number,
    acc_id              number,
    coverage_type       varchar2(30 byte),
    deductible          varchar2(255 byte),
    creation_date       date,
    created_by          number,
    last_update_date    date,
    last_updated_by     number,
    annual_election     number,
    coverage_tier_name  varchar2(255 byte),
    max_rollover_amount number,
    batch_number        number,
    coverage_tier_type  varchar2(1000 byte)
);

