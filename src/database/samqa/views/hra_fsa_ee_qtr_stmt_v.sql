create or replace force editionable view samqa.hra_fsa_ee_qtr_stmt_v (
    acc_num,
    acc_id,
    plan_start_date,
    plan_end_date,
    effective_date,
    plan_type
) as
    select
        a.acc_num,
        a.acc_id,
        trunc(plan_start_date)  plan_start_date,
        trunc(plan_end_date)    plan_end_date,
        trunc(b.effective_date) effective_date,
        b.plan_type
    from
        account                   a,
        ben_plan_enrollment_setup b
    where
            a.acc_id = b.acc_id
        and b.status = 'A'
        and not exists (
            select
                *
            from
                online_users c
            where
                c.find_key = a.acc_num
        );


-- sqlcl_snapshot {"hash":"2cd855e08fac3653035383201910c70073673787","type":"VIEW","name":"HRA_FSA_EE_QTR_STMT_V","schemaName":"SAMQA","sxml":""}