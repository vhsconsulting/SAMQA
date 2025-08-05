-- liquibase formatted sql
-- changeset SAMQA:1754374172074 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\emp_health_plans_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/emp_health_plans_v.sql:null:2c3f9306f1b594de47d17898909fe1e8561b13e1:create

create or replace force editionable view samqa.emp_health_plans_v (
    entrp_id,
    acc_num,
    carrier_name,
    effective_date,
    single_deductible,
    family_deductible,
    carrier_id,
    health_plan_id,
    status
) as
    select
        a.entrp_id,
        a.acc_num,
        c.name                                  carrier_name,
        to_char(b.effective_date, 'MM/DD/YYYY') effective_date,
        single_deductible,
        family_deductible,
        c.id                                    carrier_id,
        health_plan_id,
        b.status
    from
        account               a,
        employer_health_plans b,
        myhealthplan          c
    where
            b.carrier_id = c.entrp_id
        and a.entrp_id = b.entrp_id
        and b.show_online_flag = 'Y'
        and b.effective_end_date is null;

