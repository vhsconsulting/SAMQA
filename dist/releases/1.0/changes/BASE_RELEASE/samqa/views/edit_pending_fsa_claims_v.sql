-- liquibase formatted sql
-- changeset SAMQA:1754374171673 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\edit_pending_fsa_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/edit_pending_fsa_claims_v.sql:null:1a29b490fad3bfde054a047f1ec8b33e9d198308:create

create or replace force editionable view samqa.edit_pending_fsa_claims_v (
    claim_id,
    acc_id,
    prov_name,
    claim_code,
    request_date,
    claim_amount,
    claim_type,
    service_type,
    claim_status,
    claim_stat_meaning,
    claim_source,
    vendor_id,
    bank_acct_id
) as
    select
        a.claim_id,
        pr.acc_id,
        a.prov_name,
        a.claim_code,
        to_char(a.claim_date_start, 'MM/DD/RRRR')   request_date,
        a.claim_amount,
        b.meaning                                   claim_type,
        a.service_type,
        a.claim_status,
        pc_lookups.get_claim_status(a.claim_status) claim_stat_meaning,
        case
            when pr.claim_type in ( 'SUBSCRIBER', 'PROVIDER' ) then
                'In office'
            else
                'Online'
        end                                         claim_source,
        pr.vendor_id,
        pr.bank_acct_id
    from
        payment_register  pr,
        claimn            a,
        fsa_hra_plan_type b
    where
            a.service_type = b.lookup_code
        and pr.claim_id = a.claim_id
        and a.claim_status in ( 'PENDING_DOC', 'PENDING_REVIEW' );

