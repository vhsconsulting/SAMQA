create or replace force editionable view samqa.fsa_claims_v (
    acc_id,
    pers_id,
    claim_id,
    claim_code,
    request_date,
    claim_amount,
    claim_type_code,
    claim_type,
    claim_status,
    claim_stat_meaning,
    claim_source,
    vendor_id,
    bank_acct_id,
    claim_paid,
    claim_pending,
    approved_amount,
    denied_amount,
    denied_reason,
    reimbursement_method,
    prov_name,
    acc_num,
    entrp_id,
    approved_date
) as
    select
        pr.acc_id,
        a.pers_id,
        a.claim_id,
        a.claim_code,
        to_char(a.claim_date_start, 'MM/DD/RRRR')            request_date,
        a.claim_amount,
        b.lookup_code                                        claim_type_code,
        b.meaning                                            claim_type,
        a.claim_status,
        pc_lookups.get_claim_status(a.claim_status)          claim_stat_meaning,
        case
            when pr.claim_type in ( 'SUBSCRIBER', 'PROVIDER' ) then
                'In office'
            else
                'Online'
        end                                                  claim_source,
        pr.vendor_id,
        pr.bank_acct_id,
        nvl(a.claim_paid, 0)                                 claim_paid,
        nvl(a.claim_pending, 0)                              claim_pending,
        nvl(a.approved_amount, 0)                            approved_amount,
        nvl(a.denied_amount, 0)                              denied_amount,
        pc_lookups.get_denied_reason(a.denied_reason)        denied_reason,
        decode(pr.pay_reason, 19, 'Direct Deposit', 'Check') reimbursement_method,
        a.prov_name,
        pr.acc_num,
        a.entrp_id,
        a.approved_date
    from
        payment_register  pr,
        claimn            a,
        fsa_hra_plan_type b
    where
            a.service_type = b.lookup_code
        and pr.claim_id = a.claim_id
        and a.claim_status not in ( 'CANCELLED', 'ERROR' );


-- sqlcl_snapshot {"hash":"50af4b570c5688db92927032f73d8c91ffe5ce9c","type":"VIEW","name":"FSA_CLAIMS_V","schemaName":"SAMQA","sxml":""}