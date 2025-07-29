create or replace force editionable view samqa.claim_summary_detail_v (
    claim_id,
    service_start_date,
    service_end_date,
    claim_amount,
    patient_name
) as
    select
        claim_id,
        min(service_date)                                 service_start_date,
        max(service_end_date)                             service_end_date,
        sum(service_price *(1 + nvl(state_tax, 0) / 100)) claim_amount,
    --WM_CONCAT( DISTINCT PATIENT_DEP_NAME) PATIENT_NAME
        listagg(patient_dep_name, ',') within group(
        order by
            patient_dep_name
        )                                                 as patient_name
    from
        claim_detail
    where
        service_price is not null
    group by
        claim_id;


-- sqlcl_snapshot {"hash":"9bfda3fd4901731c0a347dbe87bf53bdd46bf6b5","type":"VIEW","name":"CLAIM_SUMMARY_DETAIL_V","schemaName":"SAMQA","sxml":""}