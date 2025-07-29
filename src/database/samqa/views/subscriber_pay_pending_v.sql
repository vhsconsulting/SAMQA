create or replace force editionable view samqa.subscriber_pay_pending_v (
    transaction_id,
    bank_acct_id,
    amount,
    transaction_date,
    reason_code,
    acc_id
) as
    select
        transaction_id,
        b.bank_acct_id,
        amount                                  amount,
        to_char(transaction_date, 'MM/DD/YYYY') transaction_date,
        reason_code,
        b.acc_id
    from
        ach_transfer   b,
        user_bank_acct c
    where
            c.acc_id = b.acc_id
        and b.bank_acct_id = c.bank_acct_id
        and b.status = 2
        and b.transaction_type = 'D';


-- sqlcl_snapshot {"hash":"191bb31cb2f8abdf51872be429ef846b4c49da2d","type":"VIEW","name":"SUBSCRIBER_PAY_PENDING_V","schemaName":"SAMQA","sxml":""}