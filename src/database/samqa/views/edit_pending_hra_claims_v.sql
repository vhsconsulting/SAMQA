create or replace force editionable view samqa.edit_pending_hra_claims_v (
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
        a.service_type                              claim_type,
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
        payment_register pr,
        claimn           a
    where
            pr.claim_id = a.claim_id
        and exists (
            select
                *
            from
                lookups
            where
                    lookup_name = 'FSA_HRA_PRODUCT_MAP'
                and a.service_type = lookup_code
                and meaning = 'HRA'
        )
        and a.claim_status in ( 'PENDING_DOC', 'PENDING_REVIEW' );


-- sqlcl_snapshot {"hash":"6373e35991890c0b9454a7cacc214828e443e4ac","type":"VIEW","name":"EDIT_PENDING_HRA_CLAIMS_V","schemaName":"SAMQA","sxml":""}