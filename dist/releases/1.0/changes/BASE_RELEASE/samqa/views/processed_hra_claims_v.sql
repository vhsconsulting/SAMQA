-- liquibase formatted sql
-- changeset SAMQA:1754374178435 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\processed_hra_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/processed_hra_claims_v.sql:null:719cba74adbe77a34f4cf75c42b531d543808c72:create

create or replace force editionable view samqa.processed_hra_claims_v (
    acc_id,
    claim_id,
    claim_code,
    prov_name,
    request_date,
    claim_amount,
    claim_category,
    claim_status,
    claim_stat_meaning,
    claim_source,
    vendor_id,
    bank_acct_id
) as
    select
        pr.acc_id,
        a.claim_id,
        a.claim_code,
        a.prov_name,
        to_char(a.claim_date_start, 'MM/DD/RRRR')   request_date,
        a.claim_amount,
        'HRA'                                       claim_category,
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
        payment_register pr,
        claimn           a
    where
        a.service_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' )
        and pr.claim_id = a.claim_id
        and a.claim_status in ( 'READY_TO_PAY', 'PAID', 'PARTIALLY_PAID', 'DENIED' );

