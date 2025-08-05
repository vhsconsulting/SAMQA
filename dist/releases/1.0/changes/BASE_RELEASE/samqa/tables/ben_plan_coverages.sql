-- liquibase formatted sql
-- changeset SAMQA:1754374152100 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ben_plan_coverages.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ben_plan_coverages.sql:null:0c6c7aa039b419c8a454b55f453deac5134f33e8:create

create table samqa.ben_plan_coverages (
    coverage_id          number,
    ben_plan_id          number,
    acc_id               number,
    coverage_type        varchar2(30 byte),
    deductible           varchar2(255 byte),
    start_date           date,
    end_date             date,
    creation_date        date,
    created_by           number,
    last_update_date     date,
    last_updated_by      number,
    fixed_funding_amount number,
    annual_election      number,
    fixed_funding_flag   varchar2(30 byte),
    deductible_rule_id   number,
    coverage_tier_name   varchar2(255 byte),
    max_rollover_amount  number default 0
);

