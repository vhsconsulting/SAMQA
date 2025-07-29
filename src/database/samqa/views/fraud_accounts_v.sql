create or replace force editionable view samqa.fraud_accounts_v (
    acc_num,
    payment_date,
    no_of_payments,
    payment_amount
) as
    select
        b.acc_num,
        to_char(pay_date, 'MM/YYYY') payment_date,
        count(*)                     no_of_payments,
        sum(amount)                  payment_amount
    from
        payment    a,
        account    b,
        pay_reason c
    where
            a.acc_id = b.acc_id
        and a.pay_date > trunc(sysdate, 'YYYY')
        and a.reason_code = c.reason_code
        and c.reason_type = 'DISBURSEMENT'
        and b.account_status <> 4
        and trunc(a.pay_date) >= sysdate
    group by
        b.acc_num,
        to_char(pay_date, 'MM/YYYY')
    having
        sum(amount) >= 5000
    order by
        4 desc;


-- sqlcl_snapshot {"hash":"1cd9dfd9b68185f95ecf405297e945b412d46f92","type":"VIEW","name":"FRAUD_ACCOUNTS_V","schemaName":"SAMQA","sxml":""}