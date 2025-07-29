create or replace force editionable view samqa.hsa_claim_report_online_v (
    acc_num,
    person_name,
    pers_id,
    entrp_id,
    acc_id,
    first_name,
    last_name,
    date_received,
    claim_amount,
    approved_amount,
    claim_pending,
    denied_amount,
    reason_code,
    reimbursement_method,
    reason_type,
    check_amount,
    transaction_number,
    check_number,
    service_type,
    claim_status,
    pay_date,
    prov_name,
    transaction_date,
    vendor_id,
    bank_acct_id,
    bank_name,
    vendor_name,
    claim_stat_meaning,
    claim_date
) as
    select
        a.acc_num,
        e.first_name
        || ' '
        || nvl(e.middle_name || ' ', ' ')
        || e.last_name                                                                  person_name,
        e.pers_id,
        e.entrp_id,
        a.acc_id,
        e.first_name,
        e.last_name,
        b.claim_date_start                                                              date_received,
        b.claim_amount,
        b.approved_amount,
        b.claim_pending,
        b.denied_amount,
        nvl(d.reason_code, b.pay_reason)                                                reason_code,
        decode(
            nvl(d.reason_code, b.pay_reason),
            19,
            'Direct Deposit',
            13,
            'Debit Card Purchase',
            'Check'
        )                                                                               reimbursement_method,
        (
            select
                reason_type
            from
                pay_reason
            where
                reason_code = nvl(d.reason_code, b.pay_reason)
        )                                                                               reason_type,
        d.amount                                                                        check_amount,
        b.claim_id                                                                      transaction_number,
        d.pay_num                                                                       check_number,
        b.service_type,
        decode(b.claim_status, 'APPROVED_NO_FUNDS', 'PENDING_APPROVAL', b.claim_status) claim_status,
        d.paid_date                                                                     pay_date,
        b.prov_name,
        d.pay_date                                                                      transaction_date,
        b.vendor_id,
        b.bank_acct_id,
        pc_user_bank_acct.get_bank_name(b.bank_acct_id)                                 bank_name,
        pc_payee.get_payee_name(b.vendor_id)                                            vendor_name,
        decode(b.claim_status,
               'PAID',
               'Processed',
               'APPROVED_NO_FUNDS',
               'Insufficient Funds',
               pc_lookups.get_claim_status(b.claim_status))                             claim_stat_meaning,
        b.claim_date
    from
        account a,
        claimn  b,
        payment d,
        person  e
    where
            a.pers_id = b.pers_id
        and e.pers_id = b.pers_id
        and b.claim_status <> 'ERROR'
    --  AND D.ACC_ID (+) = A.ACC_ID
        and d.claimn_id (+) = b.claim_id;


-- sqlcl_snapshot {"hash":"735327cca339e8878b7306b9e5451fee7a29022a","type":"VIEW","name":"HSA_CLAIM_REPORT_ONLINE_V","schemaName":"SAMQA","sxml":""}