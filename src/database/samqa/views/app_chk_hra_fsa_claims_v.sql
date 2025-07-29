create or replace force editionable view samqa.app_chk_hra_fsa_claims_v (
    entrp_id,
    entrp_name,
    reimburse_by,
    plan_type,
    no_of_claims,
    total_claim,
    approved_amount,
    denied_amount
) as
    select
        a.entrp_id,
        pc_entrp.get_entrp_name(a.entrp_id)                           entrp_name,
        case
            when pr.pay_reason in ( 11, 12 ) then
                'Cheque'
            when pr.pay_reason = 19 then
                'ACH'
        end                                                           reimburse_by,
        pc_lookups.get_meaning(a.service_type, 'FSA_HRA_PRODUCT_MAP') plan_type,
        count(a.claim_id)                                             no_of_claims,
        sum(a.claim_amount)                                           total_claim,
        sum(a.approved_amount)                                        approved_amount,
        sum(a.denied_amount)                                          denied_amount
    from
        payment_register pr,
        claimn           a,
        person           b,
        account          c
    where
            pr.claim_id = a.claim_id
        and a.claim_status = 'APPROVED_FOR_CHEQUE'
        and a.pers_id = b.pers_id
        and c.pers_id = b.pers_id
        and a.claim_amount > 0
        and c.account_type in ( 'HRA', 'FSA' )
    group by
        a.entrp_id,
        pr.pay_reason,
        a.service_type;


-- sqlcl_snapshot {"hash":"95f7f4f59af417489f41e8f88e6faa29ef699724","type":"VIEW","name":"APP_CHK_HRA_FSA_CLAIMS_V","schemaName":"SAMQA","sxml":""}