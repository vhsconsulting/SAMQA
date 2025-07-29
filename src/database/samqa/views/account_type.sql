create or replace force editionable view samqa.account_type (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'ACCOUNT_TYPE';


-- sqlcl_snapshot {"hash":"dc1af80a93a2276feaaf14ffd5da5cc0babee832","type":"VIEW","name":"ACCOUNT_TYPE","schemaName":"SAMQA","sxml":""}