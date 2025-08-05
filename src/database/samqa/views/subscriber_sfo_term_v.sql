create or replace force editionable view samqa.subscriber_sfo_term_v (
    name,
    acc_id,
    acc_num,
    plan_type,
    email,
    pers_id,
    letter_type,
    ben_plan_id,
    termination_date,
    termination_req_date
) as
    select
        a.first_name
        || ' '
        || a.middle_name
        || ' '
        || a.last_name name,
        b.acc_id,
        b.acc_num,
        e.plan_type,
        a.email,
        a.pers_id,
        'TERMINATION'  letter_type,
        e.ben_plan_id,
        e.effective_end_date,
        e.termination_req_date
    from
        person                    a,
        account                   b,
        ben_plan_enrollment_setup e
    where
            a.pers_id = b.pers_id
        and b.acc_id = e.acc_id
        and e.effective_end_date is not null
        and e.status <> 'R'
        and greatest(e.effective_end_date,
                     trunc(e.termination_req_date)) = trunc(sysdate)
        and e.sf_ordinance_flag = 'Y'
        and b.account_type in ( 'HRA', 'FSA' )
        and e.plan_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' );


-- sqlcl_snapshot {"hash":"0cd92e1219a7ae161563e408903867874b2386dc","type":"VIEW","name":"SUBSCRIBER_SFO_TERM_V","schemaName":"SAMQA","sxml":""}