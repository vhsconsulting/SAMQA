create or replace force editionable view samqa.bankserv_status (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'BANKSERV_STATUS';


-- sqlcl_snapshot {"hash":"50e5a5dea0f96df9a32695c65e2efc1aa6c9dc41","type":"VIEW","name":"BANKSERV_STATUS","schemaName":"SAMQA","sxml":""}