create or replace force editionable view samqa.hrafsa_debit_card_claims_v (
    claim_id,
    acc_num,
    plan_start_date,
    plan_end_date,
    claim_amount,
    claim_date,
    service_type,
    pers_name,
    first_name,
    middle_name,
    last_name,
    division_code,
    division_name,
    service_type_meaning,
    claim_type,
    emp_name,
    entrp_id,
    provider_name,
    paid_date,
    claim_status,
    approved_amount,
    deductible_amount,
    denied_amount,
    claim_pending,
    check_amount,
    substantiated,
    amount_remaining_for_offset,
    product_type,
    reason_code
) as
    select
        a.claim_id                                     claim_id,
        c.acc_num,
        a.plan_start_date,
        a.plan_end_date,
        to_char(b.amount)                              claim_amount,
        b.paid_date                                    claim_date,
        a.service_type,
        d.first_name
        || ' '
        || d.middle_name
        || ' '
        || d.last_name                                 pers_name,
        d.first_name,
        d.middle_name,
        d.last_name,
        d.division_code,
        pc_person.get_division_name(d.pers_id)         division_name,
        pc_benefit_plans.get_plan_name(a.service_type) service_type_meaning,
        'CLAIM'                                        claim_type,
        pc_entrp.get_entrp_name(a.entrp_id)            emp_name,
        a.entrp_id,
        nvl(a.prov_name, 'Debit Card'),
        b.paid_date,
        a.claim_status,
        a.approved_amount,
        a.deductible_amount,
        a.denied_amount,
        a.claim_pending,
        b.amount                                       check_amount,
        case
            when b.reason_code = 13 then
                nvl(a.unsubstantiated_flag, 'Y')
            else
                'N'
        end,
        case
            when nvl(a.unsubstantiated_flag, 'Y') = 'Y' then
                ( a.claim_amount - nvl(a.offset_amount, 0) )
            else
                0
        end                                            amt_rem_for_offset,
        pc_lookups.get_meaning(a.service_type, 'FSA_HRA_PRODUCT_MAP'),
        to_char(b.reason_code)                         reason_code
    from
        claimn  a,
        payment b,
        account c,
        person  d
    where
            a.claim_id = b.claimn_id
--  AND  (  B.REASON_CODE    IN (13,73,121) OR  ( B.REASON_CODE  = 12 AND NVL(A.CLAIM_SOURCE, '*') <> 'ONLINE'))
        and b.reason_code in ( 13, 73, 121 ) -- Added by Joshi for including to subscriber claims creatd from SAM.sk Enabled it back on 12/06/2023 and commented above due to  case 118497
        and c.pers_id = a.pers_id
        and c.acc_id = b.acc_id
        and c.account_type in ( 'HRA', 'FSA' )
        and a.pers_id = d.pers_id
    union all
    select
        a.change_id,
        b.acc_num,
        d.plan_start_date,
        d.plan_end_date,
        to_char(-a.amount),
        a.fee_date,
        a.plan_type,
        c.first_name
        || ' '
        || c.middle_name
        || ' '
        || c.last_name                              pers_name,
        c.first_name,
        c.middle_name,
        c.last_name,
        c.division_code,
        pc_person.get_division_name(c.pers_id)      division_name,
        pc_benefit_plans.get_plan_name(a.plan_type) service_type_meaning,
        'AUTH'                                      transaction_code,
        pc_entrp.get_entrp_name(c.entrp_id),
        c.entrp_id,
        'Pending Reversal',
        a.fee_date                                  paid_date,
        'PENDING',
        - a.amount,
        0,
        0,
        0,
        - a.amount                                  check_amount,
        'N',
        0                                           amt_rem_for_offset,
        d.product_type,
        to_char(a.reason_code)
    from
        balance_register          a,
        account                   b,
        person                    c,
        ben_plan_enrollment_setup d
    where
            a.acc_id = b.acc_id
        and b.pers_id = c.pers_id
        and b.acc_id = d.acc_id
        and a.plan_type = d.plan_type
        and a.reason_code = 22
        and d.status in ( 'A', 'I' )
        and a.fee_date between d.plan_start_date and d.plan_end_date
        and b.account_type in ( 'HRA', 'FSA' );


-- sqlcl_snapshot {"hash":"296b810caead81556498e762bcde084bfbe74a20","type":"VIEW","name":"HRAFSA_DEBIT_CARD_CLAIMS_V","schemaName":"SAMQA","sxml":""}