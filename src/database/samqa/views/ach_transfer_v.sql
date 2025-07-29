create or replace force editionable view samqa.ach_transfer_v (
    transaction_id,
    acc_num,
    bank_acct_id,
    transaction_type,
    amount,
    fee_amount,
    total_amount,
    transaction_date,
    reason_code,
    status,
    error_message,
    processed_date,
    display_name,
    bank_acct_num,
    bank_routing_num,
    acc_id,
    bank_acct_type,
    pers_id,
    entrp_id,
    bankserv_status,
    detail_count,
    account_status,
    status_desc,
    plan_type,
    claim_id,
    bank_status,
    pay_code,
    invoice_id,
    bank_acct_code,
    ach_source,
    account_type,
    creation_date,
    scheduler_id
) as
    select
        a.transaction_id,
        b.acc_num,
        a.bank_acct_id,
        a.transaction_type,
        a.amount,
        a.fee_amount,
        a.total_amount,
        a.transaction_date,
        a.reason_code,
        a.status,
        a.error_message,
        a.processed_date,
        c.display_name,
        c.bank_acct_num,
        c.bank_routing_num,
        b.acc_id,
        c.bank_acct_type,
        b.pers_id,
        b.entrp_id,
        decode(a.bankserv_status, 'APPROVED', 'Approved', null, 'Not Processed',
               'DECLINED', 'Declined', 'USER_CANCELLED', 'User Cancelled') bankserv_status,
        (
            select
                count(*)
            from
                ach_transfer_details
            where
                transaction_id = a.transaction_id
        )                                                                  detail_count,
        b.account_status,
        pc_lookups.get_account_status(b.account_status)                    status_desc,
        a.plan_type,
        a.claim_id,
        c.status,
        a.pay_code,
        a.invoice_id,
        c.bank_acct_code,
        a.ach_source,
        b.account_type,
        a.creation_date,
        a.scheduler_id
    from
        ach_transfer  a,
        account       b,
        bank_accounts c
    where
            a.acc_id = b.acc_id
        and c.bank_acct_id = a.bank_acct_id;


-- sqlcl_snapshot {"hash":"13c4183f08711910419c03b2218cb3f23768c3c2","type":"VIEW","name":"ACH_TRANSFER_V","schemaName":"SAMQA","sxml":""}