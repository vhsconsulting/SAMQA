create or replace force editionable view samqa.card_trans_detail_v (
    amount,
    pay_date,
    paid_date,
    claim_code,
    prov_name,
    acc_id,
    claim_id,
    plan_type,
    claim_status,
    status,
    days_old
) as
    select
        amount                          amount,
        to_char(pay_date, 'MM/DD/YYYY') pay_month,
        a.paid_date,
        claim_code,
        b.prov_name,
        acc_id,
        b.claim_id,
        a.plan_type,
        'Paid',
        case
            when b.substantiation_reason = 'SUPPORT_DOC_RECV'
                 and b.unsubstantiated_flag = 'Y' then
                'Documentation Received'
            else
                decode(b.unsubstantiated_flag, 'Y', 'Unsubstantiated', 'Substantiated')
        end                             reason,
        case
            when b.unsubstantiated_flag = 'Y' then
                trunc(sysdate - b.creation_date)
            else
                null
        end                             days_old
    from
        payment a,
        claimn  b
    where
            a.claimn_id = b.claim_id
        and reason_code = 13
    union all
    select
        amount,
        to_char(fee_date, 'MM/DD/YYYY') pay_month,
        fee_date,
        to_char(change_id),
        'Pending Activity',
        acc_id,
        change_id,
        plan_type,
        'Pending Debit Card Transction',
        null,
        null
    from
        balance_register
    where
        reason_code = 22;


-- sqlcl_snapshot {"hash":"88ea94e989c84c661a51466a0fd49f2cffc80443","type":"VIEW","name":"CARD_TRANS_DETAIL_V","schemaName":"SAMQA","sxml":""}