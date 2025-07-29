create or replace force editionable view samqa.subscriber_pay_processed_v (
    transaction_id,
    bank_name,
    amount,
    transaction_date,
    reason_name,
    acc_id
) as
    select
        transaction_id,
        c.display_name                          bank_name,
        amount                                  amount,
        to_char(transaction_date, 'MM/DD/YYYY') transaction_date,
        reason_name,
        b.acc_id
    from
        ach_transfer   b,
        user_bank_acct c,
        pay_reason     d
    where
            c.acc_id = b.acc_id
        and b.bank_acct_id = c.bank_acct_id
        and b.reason_code = d.reason_code
        and b.status = 3
        and b.transaction_type = 'D';


-- sqlcl_snapshot {"hash":"c0a6c611aa4162fe1a63a58dbd1da022255ac873","type":"VIEW","name":"SUBSCRIBER_PAY_PROCESSED_V","schemaName":"SAMQA","sxml":""}