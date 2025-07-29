create or replace force editionable view samqa.claim_status (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'CLAIM_STATUS';


-- sqlcl_snapshot {"hash":"2ac236d06380e51a02c43114f8ee055bedb20cba","type":"VIEW","name":"CLAIM_STATUS","schemaName":"SAMQA","sxml":""}