create or replace force editionable view samqa.er_bank_draft_schedule_v (
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
			  -- PC_SCHEDULE.get_ach_schedule(payment_start_date,SYSDATE, recurring_frequency)  schedule_date,
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
        and ( ( recurring_flag = 'N'
                and payment_start_date = trunc(sysdate) )
              or ( recurring_flag = 'Y'
                   and payment_end_date >= trunc(sysdate) ) )
        and nvl(s.status, 'A') = 'A'
        and s.amount > 0;


-- sqlcl_snapshot {"hash":"c4d9bdca01697b896ae79265240900c86244f8b9","type":"VIEW","name":"ER_BANK_DRAFT_SCHEDULE_V","schemaName":"SAMQA","sxml":""}