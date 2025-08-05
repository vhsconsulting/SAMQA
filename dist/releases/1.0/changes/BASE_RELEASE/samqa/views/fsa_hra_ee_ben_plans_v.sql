-- liquibase formatted sql
-- changeset SAMQA:1754374174026 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\fsa_hra_ee_ben_plans_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/fsa_hra_ee_ben_plans_v.sql:null:0d593ef3c16e933c6eaa2a5adc2f1c375f881b89:create

create or replace force editionable view samqa.fsa_hra_ee_ben_plans_v (
    acc_num,
    plan_start_date,
    plan_end_date,
    plan_type,
    plan_type_meaning,
    acc_id,
    ben_plan_id,
    pers_id,
    status,
    effective_date,
    effective_end_date,
    runout_period_days,
    grace_period,
    runout_period_term,
    runout_date
) as
    select
        b.acc_num,
        a.plan_start_date,
        a.plan_end_date,
        a.plan_type,
        pc_lookups.get_fsa_plan_type(a.plan_type)                                                                 plan_type_meaning,
        a.acc_id,
        a.ben_plan_id,
        b.pers_id,
        a.status,
        a.effective_date,
        a.effective_end_date,
        a.runout_period_days,
        a.grace_period,
        a.runout_period_term,
        decode(a.runout_period_term, 'CPE', a.effective_end_date, a.plan_end_date) + nvl(a.runout_period_days, 0) runout_date
    from
        ben_plan_enrollment_setup a,
        account                   b
    where
            a.acc_id = b.acc_id
        and b.pers_id is not null
        and status <> 'R';

