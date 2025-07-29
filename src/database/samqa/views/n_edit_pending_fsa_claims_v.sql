create or replace force editionable view samqa.n_edit_pending_fsa_claims_v (
    acc_id,
    claim_id,
    claim_code,
    prov_name,
    request_date,
    claim_amount,
    claim_type,
    claim_status,
    claim_stat_meaning,
    claim_source,
    vendor_id,
    bank_acct_id
) as
    select
        pr.acc_id,
        a.claim_id,
        a.claim_code,
        a.prov_name,
        to_char(a.claim_date_start, 'MM/DD/RRRR')   request_date,
        a.claim_amount,
        b.meaning                                   claim_type,
        a.claim_status,
        pc_lookups.get_claim_status(a.claim_status) claim_stat_meaning,
        case
            when pr.claim_type in ( 'SUBSCRIBER', 'PROVIDER' ) then
                'In office'
            else
                'Online'
        end                                         claim_source,
        pr.vendor_id,
        pr.bank_acct_id
    from
        payment_register  pr,
        claimn            a,
        fsa_hra_plan_type b
    where
            a.service_type = b.lookup_code
        and pr.claim_id = a.claim_id
        and a.claim_status in ( 'APPROVED_TO_DEDUCITBLE', 'AWAITING_APPROVAL', 'APPROVED', 'APPROVED_FOR_CHEQUE', 'APPROVED_NO_FUNDS'
        );


-- sqlcl_snapshot {"hash":"967b19fc2a15375827d4dfc1973907a2daa763d1","type":"VIEW","name":"N_EDIT_PENDING_FSA_CLAIMS_V","schemaName":"SAMQA","sxml":""}