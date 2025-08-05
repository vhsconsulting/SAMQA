-- liquibase formatted sql
-- changeset SAMQA:1754374170132 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\claims_deductible_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/claims_deductible_v.sql:null:db8fc8809b4f41ff9e320604fa496e5ee35fc40b:create

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

