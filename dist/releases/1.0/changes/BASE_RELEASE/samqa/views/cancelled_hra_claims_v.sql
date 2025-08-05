-- liquibase formatted sql
-- changeset SAMQA:1754374169547 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\cancelled_hra_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/cancelled_hra_claims_v.sql:null:f5d6bc3a31923328cfe6c70bcde7c6bc0c259e07:create

create or replace force editionable view samqa.cancelled_hra_claims_v (
    claim_id,
    acc_id,
    provider_name,
    trans_date,
    claim_amount,
    claim_category,
    vendor_id,
    bank_acct_id
) as
    select
        pr.claim_id,
        pr.acc_id,
        pr.provider_name,
        to_char(pr.trans_date, 'MM/DD/YYYY') trans_date,
        pr.claim_amount,
        'HRA'                                claim_category,
        pr.vendor_id,
        pr.bank_acct_id
    from
        payment_register pr
    where
            pr.cancelled_flag = 'Y'
        and not exists (
            select
                *
            from
                claimn
            where
                    claimn.claim_id = pr.claim_id
                and claimn.claim_status = 'ERROR'
        )
        and exists (
            select
                *
            from
                lookups
            where
                    lookup_name = 'FSA_HRA_PRODUCT_MAP'
                and lookup_code = pr.service_type
                and meaning = 'HRA'
        );

