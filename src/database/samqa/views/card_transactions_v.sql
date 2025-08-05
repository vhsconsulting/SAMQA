create or replace force editionable view samqa.card_transactions_v (
    amount,
    pay_month,
    check_number,
    prov_name,
    acc_id
) as
    select
        sum(amount)                   amount,
        to_char(pay_date, 'MON-YYYY') pay_month,
        pay_num                       check_number,
        b.prov_name,
        acc_id
    from
        payment a,
        claimn  b
    where
            a.claimn_id = b.claim_id
        and reason_code = 13
        and pay_date > trunc(sysdate, 'YYYY')
    group by
        to_char(pay_date, 'MON-YYYY'),
        pay_num,
        b.prov_name,
        acc_id;


-- sqlcl_snapshot {"hash":"d2f61d759c35344f10dda1c837d0fdbc56f28427","type":"VIEW","name":"CARD_TRANSACTIONS_V","schemaName":"SAMQA","sxml":""}