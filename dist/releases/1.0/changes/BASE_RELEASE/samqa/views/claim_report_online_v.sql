-- liquibase formatted sql
-- changeset SAMQA:1754374170083 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\claim_report_online_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/claim_report_online_v.sql:null:d95a377960022a0fb1a3cd3a6a50368b1077e22f:create

create or replace force editionable view samqa.claim_report_online_v (
    acc_num,
    person_name,
    first_name,
    last_name,
    entrp_id,
    date_received,
    claim_amount,
    approved_amount,
    claim_pending,
    denied_amount,
    reason_code,
    reimbursement_method,
    check_amount,
    transaction_number,
    check_number,
    service_type,
    service_type_meaning,
    er_acc_num,
    claim_status,
    pay_date,
    deductible_amount,
    provider_name,
    division_code,
    division_name,
    plan_start_date,
    plan_end_date,
    transaction_date,
    pers_id,
    product_type
) as
    select
        a.acc_num,
        pc_person.get_person_name(b.pers_id)                       person_name,
        e.first_name,
        e.last_name,
        e.entrp_id,
        b.claim_date_start                                         date_received,
        b.claim_amount,
        b.approved_amount,
        b.claim_pending,
        b.denied_amount,
        d.reason_code,
        case
            when b.claim_amount >= b.deductible_amount
                 and b.approved_amount = 0
                 and b.deductible_amount > 0 then
                'Applied to Deductible'
            when c.payroll_integration = 'Y'     then
                'Payroll Integration'
            when b.takeover = 'Y'                then
                'Take Over'
            when d.reason_code in ( 27, 28, 29, 60, 73,
                                    74 ) then
                pc_lookups.get_reason_name(d.reason_code)
            when denied_reason = 'OFFSET_REASON' then
                'Offset for Debit Card Claim' || b.source_claim_id
            else
                decode(d.reason_code,
                       19,
                       'Direct Deposit',
                       13,
                       'Debit Card Purchase',
                       pc_lookups.get_reason_name(d.reason_code))
        end                                                        reimbursement_method,
        d.amount                                                   check_amount,
        b.claim_id                                                 transaction_number,
        d.pay_num                                                  check_number,
        b.service_type,
        pc_lookups.get_fsa_plan_type(d.plan_type)                  service_type_meaning,
        c.acc_num                                                  er_acc_num,
        b.claim_status,
        trunc(d.paid_date)                                         pay_date,
        b.deductible_amount,
        b.prov_name                                                provider_name,
        pc_person.get_division_code(b.pers_id)                     division_code,
        pc_person.get_division_name(b.pers_id)                     division_name,
        b.plan_start_date,
        b.plan_end_date,
        d.pay_date                                                 transaction_date,
        e.pers_id,
        pc_lookups.get_meaning(d.plan_type, 'FSA_HRA_PRODUCT_MAP') product_type
    from
        payment_register a,
        claimn           b,
        account          c,
        payment          d,
        person           e
    where
            a.entrp_id = b.entrp_id
        and c.entrp_id = b.entrp_id
        and a.claim_id = b.claim_id
        and e.pers_id = b.pers_id
        and d.acc_id = a.acc_id
        and d.reason_code <> 13
        and b.claim_status not in ( 'ERROR', 'CANCELLED' )
        and d.claimn_id = b.claim_id;

