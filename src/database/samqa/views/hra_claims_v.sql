create or replace force editionable view samqa.hra_claims_v (
    acc_num,
    acc_id,
    pers_id,
    claim_id,
    claim_code,
    request_date,
    claim_amount,
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
    entrp_id,
    approved_date,
    prov_name
) as
    select
        pr.acc_num,
        pr.acc_id,
        a.pers_id,
        a.claim_id,
        a.claim_code,
        to_char(a.claim_date_start, 'MM/DD/RRRR')      request_date,
        a.claim_amount,
        'HRA'                                          claim_type,
        a.claim_status,
        pc_lookups.get_claim_status(a.claim_status)    claim_stat_meaning,
        case
            when pr.claim_type in ( 'SUBSCRIBER', 'PROVIDER' ) then
                'In office'
            else
                'Online'
        end                                            claim_source,
        pr.vendor_id,
        pr.bank_acct_id,
        nvl(a.claim_paid, 0)                           claim_paid,
        nvl(a.claim_pending, 0)                        claim_pending,
        nvl(a.approved_amount, 0)                      approved_amount,
        nvl(a.denied_amount, 0)                        denied_amount,
        pc_lookups.get_denied_reason(a.denied_reason)  denied_reason,
        decode(pr.bank_acct_id, null, 'Cheque', 'ACH') reimbursement_method,
        a.entrp_id,
        a.approved_date,
        pr.provider_name                               prov_name
    from
        payment_register pr,
        claimn           a
    where
        a.service_type in ( 'HRA', 'HR5', 'HRP', 'ACO', 'HR4' )
        and pr.claim_id = a.claim_id
        and a.claim_status <> 'ERROR';


-- sqlcl_snapshot {"hash":"c4426fee6b6850665ea07dbfc70892b38911b038","type":"VIEW","name":"HRA_CLAIMS_V","schemaName":"SAMQA","sxml":""}