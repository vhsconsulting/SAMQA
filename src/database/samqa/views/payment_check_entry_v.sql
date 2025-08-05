create or replace force editionable view samqa.payment_check_entry_v (
    name,
    last_name,
    acc_num,
    claim_code,
    prov_name,
    amount,
    claim_creation_date,
    claim_date_end,
    pay_num,
    note,
    change_num,
    claim_amount,
    balance,
    claim_id,
    pers_id,
    reason_code,
    acc_id
) as
    select
        first_name
        || ' '
        || middle_name
        || ' '
        || last_name                          name,
        last_name,
        d.acc_num                             acc_num,
        claim_code,
        prov_name,
        nvl(amount, 0)                        amount,
        claim_date_start                      claim_creation_date,
        nvl(claim_date_end, claim_date_start) claim_date_end,
        pay_num,
        c.note,
        c.change_num,
        sum(nvl(amount, 0))
        over(partition by c.acc_id,
                          a.claim_id)                       claim_amount,
        nvl(
            pc_account.acc_balance(c.acc_id),
            0
        )                                     balance,
        a.claim_id,
        b.pers_id,
        c.reason_code,
        d.acc_id
    from
        claimn  a,
        person  b,
        account d,
        payment c
    where
        c.pay_num is null
        and c.reason_code in ( 11, 12 )
        and a.claim_id = c.claimn_id
        and a.pers_id = b.pers_id
        and d.pers_id = b.pers_id
        and d.account_type = 'HSA'
    order by
        claim_date_end desc;


-- sqlcl_snapshot {"hash":"0337d4ea5a13467530c157bed0bf70cbc842c7ab","type":"VIEW","name":"PAYMENT_CHECK_ENTRY_V","schemaName":"SAMQA","sxml":""}