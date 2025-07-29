create or replace force editionable view samqa.cancelled_fsa_claims_v (
    claim_id,
    acc_id,
    provider_name,
    trans_date,
    claim_amount,
    claim_category,
    vendor_id,
    bank_acct_id
) as
    select
        pr.claim_id,
        pr.acc_id,
        pr.provider_name,
        to_char(pr.trans_date, 'MM/DD/YYYY'),
        pr.claim_amount,
        b.meaning claim_category,
        pr.vendor_id,
        pr.bank_acct_id
    from
        payment_register  pr,
        fsa_hra_plan_type b
    where
            pr.cancelled_flag = 'Y'
        and not exists (
            select
                *
            from
                claimn
            where
                    claimn.claim_id = pr.claim_id
                and claimn.claim_status = 'ERROR'
        )
        and pr.service_type = b.lookup_code;


-- sqlcl_snapshot {"hash":"92cc583cb7ce11062f2986054cb3791c93923df8","type":"VIEW","name":"CANCELLED_FSA_CLAIMS_V","schemaName":"SAMQA","sxml":""}