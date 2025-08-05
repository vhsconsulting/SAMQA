-- liquibase formatted sql
-- changeset SAMQA:1754374160243 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\mass_enroll_plans.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/mass_enroll_plans.sql:null:d246ecbd005915570363f7fc5f9ab72ad535ba7b:create

create table samqa.mass_enroll_plans (
    mass_enroll_plan_id number,
    plan_type           varchar2(255 byte),
    deductible          varchar2(30 byte),
    effective_date      varchar2(200 byte),
    annual_election     varchar2(255 byte),
    first_payroll_date  varchar2(200 byte),
    pay_contrb          varchar2(255 byte),
    no_of_periods       varchar2(255 byte),
    pay_cycle           varchar2(255 byte),
    action              varchar2(255 byte),
    plan_code           varchar2(255 byte),
    covg_tier_name      varchar2(255 byte),
    conditional_issue   varchar2(31 byte),
    broker_number       varchar2(300 byte),
    note                varchar2(3200 byte),
    batch_number        varchar2(200 byte),
    mass_enrollment_id  number,
    creation_date       date,
    created_by          varchar2(30 byte),
    last_update_date    date,
    last_updated_by     varchar2(30 byte),
    ben_plan_id         varchar2(10 byte),
    status              varchar2(1000 byte),
    termination_date    varchar2(30 byte),
    er_ben_plan_id      number
);

alter table samqa.mass_enroll_plans add primary key ( mass_enroll_plan_id )
    using index enable;

