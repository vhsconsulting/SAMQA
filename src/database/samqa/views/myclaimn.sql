create or replace force editionable view samqa.myclaimn (
    claim_id,
    pers_id,
    pers_patient,
    claim_code,
    prov_name,
    claim_date_start,
    claim_date_end,
    tax_code,
    service_status,
    claim_amount,
    claim_paid,
    claim_pending,
    note
) as
    (
        select
            claim_id,
            pers_id,
            pers_patient,
            claim_code,
            prov_name,
            claim_date_start,
            claim_date_end,
            tax_code,
            service_status,
            claim_amount,
            claim_paid,
            claim_pending,
            note
        from
            claimn
    );


-- sqlcl_snapshot {"hash":"81a0a6fdb18f41fe6d0009c4607c5411488f9908","type":"VIEW","name":"MYCLAIMN","schemaName":"SAMQA","sxml":""}