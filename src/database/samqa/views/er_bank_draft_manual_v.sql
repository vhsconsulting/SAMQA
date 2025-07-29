create or replace force editionable view samqa.er_bank_draft_manual_v (
    scheduler_id,
    m_acc_id,
    payment_method,
    payment_type,
    reason_code,
    payment_start_date,
    payment_end_date,
    recurring_flag,
    amount,
    fee_amount,
    bank_acct_id,
    contributor,
    plan_type,
    recurring_frequency,
    claim_id
) as
    select
        scheduler_id,
        s.acc_id                                                    m_acc_id,
        payment_method,
        payment_type,
        reason_code,
        payment_start_date,
        payment_end_date,
        recurring_flag,
        amount,
        fee_amount,
        bank_acct_id,
        contributor,
        plan_type,
        recurring_frequency,
        decode(orig_system_source, 'CLAIMN', orig_system_ref, null) claim_id
    from
        scheduler_master s
    where
            s.payment_method = 'ACH'
        and nvl(s.status, 'A') = 'A'
        and s.amount > 0;


-- sqlcl_snapshot {"hash":"50f3a76349ba5856ee7e2a4964218d2a9de0c50d","type":"VIEW","name":"ER_BANK_DRAFT_MANUAL_V","schemaName":"SAMQA","sxml":""}