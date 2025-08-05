create or replace force editionable view samqa.daily_claim_count_v (
    no_of_claims,
    claim_type
) as
    select
        count(*)                               no_of_claims,
        initcap(replace(claim_type, '_', ' ')) claim_type
    from
        payment_register
    where
            nvl(cancelled_flag, 'N') = 'N'
        and nvl(claim_error_flag, 'N') = 'N'
        and nvl(insufficient_fund_flag, 'N') = 'N'
        and trunc(creation_date) > trunc(sysdate)
    group by
        claim_type
    union
    select
        count(*),
        'Debit Card Purchase'
    from
        metavante_settlements a
    where
            a.created_claim = 'Y'
        and trunc(a.creation_date) = trunc(sysdate);


-- sqlcl_snapshot {"hash":"18457e2df0a8e06a6fddc1176628f8573b77ca57","type":"VIEW","name":"DAILY_CLAIM_COUNT_V","schemaName":"SAMQA","sxml":""}