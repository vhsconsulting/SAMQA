-- liquibase formatted sql
-- changeset SAMQA:1754374177506 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\n_edit_pending_hra_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/n_edit_pending_hra_claims_v.sql:null:7704108e472ebc9a0799b0e4e5d2adc3ec2a94e8:create

create or replace force editionable view samqa.n_edit_pending_hra_claims_v (
    acc_id,
    claim_id,
    claim_code,
    prov_name,
    request_date,
    claim_amount,
    claim_type,
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
        a.service_type                              claim_type,
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
            pr.claim_id = a.claim_id
        and a.service_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' )
        and a.claim_status in ( 'APPROVED_TO_DEDUCITBLE', 'AWAITING_APPROVAL', 'APPROVED', 'APPROVED_FOR_CHEQUE', 'APPROVED_NO_FUNDS'
        );

