create or replace force editionable view samqa.ach_emp_detail_v (
    group_id,
    acct_id,
    first_name,
    last_name,
    employer_contrib,
    employee_contrib,
    ee_fee_amount,
    er_fee_amount,
    total_contrib,
    transaction_id,
    transaction_date,
    xfer_detail_id,
    reason_code,
    bank_acct_id,
    bank,
    acc_id,
    group_acc_id,
    pers_id,
    entrp_id,
    account_status,
    status,
    bankserv_status,
    transaction_type,
    total_amount,
    pay_code
) as
    select
        c.acc_num                                                                                   group_id,
        d.acc_num                                                                                   acct_id,
        e.first_name,
        e.last_name,
        b.er_amount                                                                                 employer_contrib,
        b.ee_amount                                                                                 employee_contrib,
        b.ee_fee_amount,
        b.er_fee_amount,
        nvl(b.er_amount, 0) + nvl(b.ee_amount, 0) + nvl(b.ee_fee_amount, 0) + nvl(er_fee_amount, 0) total_contrib,
        a.transaction_id,
        a.transaction_date,
        xfer_detail_id,
        reason_code,
        bank_acct_id,
        (
            select
                bank_name
                || ' '
                || bank_routing_num
                || '/'
                || bank_acct_num
            from
                user_bank_acct
            where
                bank_acct_id = a.bank_acct_id
        )                                                                                           bank,
        d.acc_id,
        c.acc_id                                                                                    group_acc_id,
        e.pers_id,
        e.entrp_id,
        d.account_status,
        a.status,
        a.bankserv_status,
        a.transaction_type,
        a.total_amount,
        a.pay_code
    from
        ach_transfer         a,
        ach_transfer_details b,
        account              c,
        account              d,
        person               e
    where
            a.transaction_id = b.transaction_id
        and a.acc_id = c.acc_id
    --  AND c.entrp_id IS NOT NULL
        and b.group_acc_id = c.acc_id
        and b.acc_id = d.acc_id
        and d.pers_id = e.pers_id;


-- sqlcl_snapshot {"hash":"c1e9da1546fa9d0a413bb2c702844cc67907c7fc","type":"VIEW","name":"ACH_EMP_DETAIL_V","schemaName":"SAMQA","sxml":""}