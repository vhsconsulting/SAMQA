-- liquibase formatted sql
-- changeset SAMQA:1754374172383 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\employer_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/employer_claims_v.sql:null:467994e4153dc7dc057c2e592fa14c2b8955adcb:create

create or replace force editionable view samqa.employer_claims_v (
    entrp_id,
    service_type,
    service_type_meaning,
    entrp_name,
    no_of_claims,
    total_claim,
    approved_amount,
    denied_amount,
    account_type,
    approved_date
) as
    select
        b.entrp_id,
        a.service_type,
  --  A.CLAIM_STATUS,
   -- PC_LOOKUPS.GET_CLAIM_STATUS(A.CLAIM_STATUS) CLAIM_STAT_MEANING,
        pc_lookups.get_fsa_plan_type(a.service_type) service_type_meaning,
        pc_entrp.get_entrp_name(b.entrp_id)          entrp_name,
        count(a.claim_id)                            no_of_claims,
        sum(claim_amount)                            total_claim,
        sum(approved_amount)                         approved_amount,
        sum(denied_amount)                           denied_amount,
        c.account_type,
        trunc(a.approved_date)                       approved_date
    from
        claimn  a,
        person  b,
        account c
    where
            a.pers_id = b.pers_id
        and c.pers_id = b.pers_id
        and a.claim_status not in ( 'ERROR', 'CANCELLED' )
    group by
        b.entrp_id,
        a.service_type,
        b.entrp_id,
        c.account_type,
        trunc(a.approved_date);

