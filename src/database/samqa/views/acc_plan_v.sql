create or replace force editionable view samqa.acc_plan_v (
    acc_num,
    pers_name,
    plan_name,
    start_date,
    entrp_id,
    pers_id,
    acc_id,
    plan_code,
    note,
    account_status,
    plan_change_date,
    hsa_effective_date,
    confirmation_date
) as
    select
        acc_num,
        first_name
        || ' '
        || middle_name
        || ' '
        || last_name pers_name,
        c.plan_name,
        a.start_date,
        b.entrp_id,
        a.pers_id,
        a.acc_id,
        a.plan_code,
        a.note,
        a.account_status,
        a.plan_change_date,
        a.hsa_effective_date,
        a.confirmation_date
    from
        account a,
        person  b,
        plans   c
    where
            a.pers_id = b.pers_id
        and a.plan_code = c.plan_code
    union all
    select
        acc_num,
        name,
        c.plan_name,
        a.start_date,
        b.entrp_id,
        null,
        a.acc_id,
        a.plan_code,
        a.note,
        a.account_status,
        a.plan_change_date,
        a.hsa_effective_date,
        a.confirmation_date
    from
        account    a,
        enterprise b,
        plans      c
    where
            a.entrp_id = b.entrp_id
        and a.plan_code = c.plan_code;


-- sqlcl_snapshot {"hash":"b5345a8441400a5666fb9b450c76de65169b812b","type":"VIEW","name":"ACC_PLAN_V","schemaName":"SAMQA","sxml":""}