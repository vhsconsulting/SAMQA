create or replace force editionable view samqa.all_claims_v (
    acc_num,
    first_name,
    last_name,
    pay_date,
    approved_amount,
    claim_pending,
    check_amount,
    check_number,
    claim_id,
    claim_amount,
    transaction_number,
    reimbursement_method,
    division_code,
    division_name,
    reason_code,
    service_type,
    service_type_meaning,
    denied_amount,
    plan_start_date,
    plan_end_date,
    claim_category,
    paid_date,
    entrp_id,
    product_type,
    claim_date,
    substantiated,
    off_amt
) as
    select
        acc_num,
        first_name,
        last_name,
        to_char(pay_date, 'mm/dd/yyyy') pay_date,
        approved_amount,
        claim_pending,
        check_amount,
        check_number,
        transaction_number              claim_id,
        claim_amount,
        transaction_number,
        reimbursement_method,
        division_code,
        division_name,
        reason_code,
        service_type,
        service_type_meaning,
        denied_amount,
        plan_start_date,
        plan_end_date,
        'MANUAL'                        claim_category,
        pay_date                        paid_date,
        entrp_id,
        product_type,
        transaction_date                claim_date,
        null                            substantiated,
        to_number(0.00)                 off_amt
    from
        claim_report_online_v
    where
        reason_code <> 73
    union all
    select
        c.acc_num,
        first_name,
        last_name,
        to_char(paid_date, 'MM/DD/YYYY')             pay_date,
        b.approved_amount,
        b.claim_pending,
        to_number(claim_amount)                      check_amount,
        null                                         check_number,
        b.claim_id,
        to_number(b.claim_amount)                    claim_amount,
        b.claim_id                                   transaction_number,
        'Debit Card Purchase'                        reimbursement_method,
        pc_person.get_division_code(c.pers_id)       division_code,
        pc_person.get_division_name(c.pers_id)       division_name,
        0                                            reason_code,
        b.service_type                               service_type,
        pc_lookups.get_fsa_plan_type(b.service_type) service_type_meaning,
        b.denied_amount,
        b.plan_start_date,
        b.plan_end_date,
        'DEBIT_CARD_CLAIM'                           claim_category,
        paid_date,
        b.entrp_id,
        product_type,
        b.claim_date                                 claim_date,
        b.substantiated,
        ( nvl(amount_remaining_for_offset, 0) )      off_amt
    from
        hrafsa_debit_card_claims_v b,
        account                    c
    where
            c.acc_num = b.acc_num --and b.acc_num = 'FSA007765'
        and claim_status not in ( 'ERROR', 'CANCELLED' )
    union all
    select
        c.acc_num,
        first_name,
        last_name,
        null                                         pay_date,
        b.approved_amount,
        b.claim_pending,
        null                                         check_amount,
        null                                         check_number,
        b.claim_id,
        to_number(b.claim_amount)                    claim_amount,
        b.claim_id                                   transaction_number,
        'Denied'                                     reimbursement_method,
        pc_person.get_division_code(b.pers_id)       division_code,
        pc_person.get_division_name(b.pers_id)       division_name,
        0                                            reason_code,
        b.service_type                               service_type,
        pc_lookups.get_fsa_plan_type(b.service_type) service_type_meaning,
        b.denied_amount,
        b.plan_start_date,
        b.plan_end_date,
        'MANUAL'                                     claim_category,
        trunc(claim_date)                            claim_date,
        a.entrp_id,
        pc_lookups.get_meaning(b.service_type, 'FSA_HRA_PRODUCT_MAP'),
        b.claim_date                                 claim_date,
        null                                         substantiated,
        to_number(0.00)                              off_amt
    from
        payment_register a,
        claimn           b,
        account          c,
        person           e
    where
            a.entrp_id = b.entrp_id
        and e.entrp_id = b.entrp_id
        and a.claim_id = b.claim_id
        and e.pers_id = b.pers_id
        and c.pers_id = b.pers_id  ---New
        and b.claim_status = 'DENIED'
        and b.claim_status not in ( 'ERROR', 'CANCELLED' );


-- sqlcl_snapshot {"hash":"31f0c4c05db1b7375226a82709ab930ad2883d20","type":"VIEW","name":"ALL_CLAIMS_V","schemaName":"SAMQA","sxml":""}