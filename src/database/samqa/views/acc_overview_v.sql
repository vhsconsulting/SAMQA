create or replace force editionable view samqa.acc_overview_v (
    name,
    acc_num,
    start_date,
    acc_balance,
    available_balance,
    plan_name,
    acc_id,
    pers_id,
    ssn,
    card_count,
    enroll_flag,
    account_type,
    account_status,
    tax_id,
    entrp_id,
    address,
    city,
    state,
    zip,
    phone_day,
    closed_reason,
    show_account_online
) as
    select
        first_name
        || ' '
        || last_name                              name,
        acc_num,
        to_char(hsa_effective_date, 'MM/DD/YYYY') start_date,
        pc_account.acc_balance(acc_id)            acc_balance,
        pc_account.current_balance(acc_id)        available_balance,
        plan_name,
        a.acc_id,
        a.pers_id,
        b.ssn,
        (
            select
                count(*)
            from
                card_debit
            where
                card_id = b.pers_id
        )                                         card_count,
        (
            select
                count(*)
            from
                online_enrollment d
            where
                d.acc_num = a.acc_num
        )                                         enroll_flag,
        a.account_type,
        a.account_status,
        replace(b.ssn, '-')                       tax_id,
        b.entrp_id,
        b.address,
        b.city,
        b.state,
        b.zip,
        b.phone_day,
        a.closed_reason,
        a.show_account_online  -- Added by Swamy for Ticket#9332 on 06/11/2020
    from
        account a,
        person  b,
        plans   c
    where
            a.pers_id = b.pers_id
        and a.plan_code = c.plan_code;


-- sqlcl_snapshot {"hash":"f6fe2049e141ab39dcda2a8fa2fdda0fc12d7d4f","type":"VIEW","name":"ACC_OVERVIEW_V","schemaName":"SAMQA","sxml":""}