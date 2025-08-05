-- liquibase formatted sql
-- changeset SAMQA:1754374172671 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\enroll_qtr_ee_plan_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/enroll_qtr_ee_plan_v.sql:null:98e983927ae7852f7272fd246023333f7bede818:create

create or replace force editionable view samqa.enroll_qtr_ee_plan_v (
    first_name,
    middle_name,
    last_name,
    name,
    address,
    city,
    state,
    zip,
    phone_day,
    plan_type_meaning,
    plan_type,
    annual_election,
    available_balance,
    acc_id,
    acc_num,
    start_date,
    plan_end_date,
    plan_start_date,
    account_type,
    runout_period_days,
    grace_period,
    ben_plan_id,
    effective_date,
    ben_plan_name
) as
    select
        a.first_name,
        a.middle_name,
        a.last_name,
        a.first_name
        || ' '
        || a.middle_name
        || ' '
        || a.last_name                                                                                    name,
        a.address,
        a.city,
        a.state,
        a.zip,
        a.phone_day,
        pc_lookups.get_fsa_plan_type(c.plan_type)                                                         plan_type_meaning,
        c.plan_type,
        c.annual_election,
        pc_account.acc_balance(b.acc_id, c.plan_start_date, c.plan_end_date, b.account_type, c.plan_type) available_balance,
        b.acc_id,
        b.acc_num,
        to_char(start_date, 'MM/DD/YYYY')                                                                 start_date,
        trunc(c.plan_end_date)                                                                            plan_end_date,
        trunc(c.plan_start_date)                                                                          plan_start_date,
        b.account_type,
        c.runout_period_days,
        nvl(c.grace_period, 0)                                                                            grace_period,
        c.ben_plan_id,
        to_char(c.effective_date, 'MM/DD/YYYY')                                                           effective_date,
        c.ben_plan_name
    from
        person                    a,
        account                   b,
        ben_plan_enrollment_setup c
    where
            a.pers_id = b.pers_id
        and c.acc_id = b.acc_id
        and c.status = 'A'
        and b.account_status not in ( 4, 5 );

