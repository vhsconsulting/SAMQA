create or replace force editionable view samqa.claims_deductible_v (
    claim_id,
    acc_num,
    plan_type,
    annual_election,
    plan_start_date,
    plan_end_date,
    claim_amount,
    deductible_amount,
    approved_amount
) as
    select
        claim_id,
        acc_num,
        plan_type,
        annual_election,
        plan_start_date,
        plan_end_date,
        claim_amount,
        deductible_amount,
        approved_amount
    from
        table ( pc_claim.get_deductible_report() );


-- sqlcl_snapshot {"hash":"db8fc8809b4f41ff9e320604fa496e5ee35fc40b","type":"VIEW","name":"CLAIMS_DEDUCTIBLE_V","schemaName":"SAMQA","sxml":""}