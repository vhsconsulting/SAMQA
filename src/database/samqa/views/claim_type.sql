create or replace force editionable view samqa.claim_type (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'CLAIM_TYPE';


-- sqlcl_snapshot {"hash":"4de5b599702c65fe74672816b313d03bad0d119a","type":"VIEW","name":"CLAIM_TYPE","schemaName":"SAMQA","sxml":""}