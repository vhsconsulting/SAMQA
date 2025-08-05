-- liquibase formatted sql
-- changeset SAMQA:1754374156152 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\employer_health_plans_back.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/employer_health_plans_back.sql:null:f54c9cc4a1b5a951d04f99d597f3db97b0300ac3:create

create table samqa.employer_health_plans_back (
    health_plan_id      number,
    entrp_id            number,
    carrier_id          number,
    single_deductible   number,
    family_deductible   number,
    single_contribution number,
    family_contribution number,
    effective_date      date,
    creation_date       date,
    created_by          number,
    last_update_date    date,
    last_updated_by     number,
    effective_end_date  date,
    status              varchar2(1 byte),
    renewal_date        date,
    show_online_flag    varchar2(1 byte),
    deductible          number,
    plan_type           number
);

