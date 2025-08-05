-- liquibase formatted sql
-- changeset SAMQA:1754374178074 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\pending_hra_fsa_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/pending_hra_fsa_claims_v.sql:null:f315f921045f94212897bd4202259dc18d4a217d:create

create or replace force editionable view samqa.pending_hra_fsa_claims_v (
    entrp_id,
    entrp_name,
    no_of_claims,
    total_claim,
    approved_amount,
    denied_amount,
    pay_reason
) as
    select
        b.entrp_id,
        pc_entrp.get_entrp_name(b.entrp_id) entrp_name,
        count(a.claim_id)                   no_of_claims,
        sum(a.claim_amount)                 total_claim,
        sum(a.approved_amount)              approved_amount,
        sum(a.denied_amount)                denied_amount,
        case
            when d.pay_reason in ( 11, 12 ) then
                'Check'
            when d.pay_reason = 19 then
                'ACH'
        end                                 pay_reason
    from
        claimn           a,
        person           b,
        account          c,
        payment_register d
    where
        claim_status not in ( 'PAID', 'DENIED', 'CANCELLED' )
        and a.pers_id = b.pers_id
        and d.claim_id = a.claim_id
        and d.acc_id = c.acc_id
        and c.acc_num = d.acc_num
        and c.pers_id = b.pers_id
        and c.account_type in ( 'HRA', 'FSA' )
    group by
        b.entrp_id,
        pc_entrp.get_entrp_name(b.entrp_id),
        d.pay_reason;

