create or replace force editionable view samqa.person_county_v (
    lookup_name,
    lookup_code,
    county
) as
    select
        lookup_name,
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'COUNTY';


-- sqlcl_snapshot {"hash":"68ceea61858ca14ae9f0ec9cf779c10d59e2f473","type":"VIEW","name":"PERSON_COUNTY_V","schemaName":"SAMQA","sxml":""}