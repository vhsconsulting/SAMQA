create or replace force editionable view samqa.fsa_hra_rollover_report_v (
    acc_num,
    name,
    plan_start,
    plan_end,
    plan_end_date,
    plan_type,
    rollover_count,
    no_of_employees,
    ee_current_plan,
    ben_plan_id,
    entrp_id
) as
    select
        a.acc_num,
        c.name,
        to_char(b.plan_start_date, 'MM/DD/YYYY')                              plan_start,
        to_char(b.plan_end_date, 'MM/DD/YYYY')                                plan_end,
        b.plan_end_date + nvl(b.grace_period, 0) + nvl(runout_period_days, 0) plan_end_date,
        b.plan_type,
        (
            select
                count(*)
            from
                employer_deposits
            where
                    reason_code = 17
                and check_date > b.plan_end_date
                and entrp_id = a.entrp_id
                and plan_type = b.plan_type
        )                                                                     rollover_count,
        (
            select
                count(*)
            from
                fsa_hra_employees_v fv
            where
                fv.ben_plan_id_main = b.ben_plan_id
        )                                                                     no_of_employees,
        (
            select
                count(*)
            from
                fsa_hra_employees_v fv
            where
                    fv.ben_plan_id_main > b.ben_plan_id
                and fv.plan_type = b.plan_type
                and fv.entrp_id = b.entrp_id
        )                                                                     ee_current_plan,
        b.ben_plan_id,
        a.entrp_id
    from
        account                   a,
        ben_plan_enrollment_setup b,
        enterprise                c
    where
            a.entrp_id = c.entrp_id
        and a.acc_id = b.acc_id
        and b.rollover = 'Y'
        and b.plan_end_date + nvl(b.grace_period, 0) + nvl(runout_period_days, 0) >= trunc(add_weeks(sysdate, 3))
        and exists (
            select
                *
            from
                fsa_hra_employees_v fv
            where
                    fv.ben_plan_id_main = b.ben_plan_id
                and fv.acc_balance > 0
        )
        and exists (
            select
                *
            from
                ben_plan_enrollment_setup bp
            where
                    bp.acc_id = b.acc_id
                and b.plan_type = bp.plan_type
                and bp.ben_plan_id > b.ben_plan_id
        )
        and ( b.plan_type in ( 'FSA', 'LPF' )
              or b.product_type = 'HRA' );


-- sqlcl_snapshot {"hash":"abc7f4d84aa996857d449dc4391f7be7f45e9780","type":"VIEW","name":"FSA_HRA_ROLLOVER_REPORT_V","schemaName":"SAMQA","sxml":""}