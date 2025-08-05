-- liquibase formatted sql
-- changeset SAMQA:1754374156135 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\employer_health_plans.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/employer_health_plans.sql:null:512ac8938e3a1af247fffdd6f554fd884fadb9d5:create

create table samqa.employer_health_plans (
    health_plan_id      number,
    entrp_id            number,
    carrier_id          number,
    single_deductible   number,
    family_deductible   number,
    single_contribution number,
    family_contribution number,
    effective_date      date,
    creation_date       date default sysdate,
    created_by          number,
    last_update_date    date default sysdate,
    last_updated_by     number,
    effective_end_date  date,
    status              varchar2(1 byte) default 'A',
    renewal_date        date,
    show_online_flag    varchar2(1 byte) default 'Y',
    deductible          number,
    plan_type           number
);

