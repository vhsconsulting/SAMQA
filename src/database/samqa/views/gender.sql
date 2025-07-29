create or replace force editionable view samqa.gender (
    gender_code,
    gender
) as
    select
        lookup_code gender_code,
        meaning     gender
    from
        lookups
    where
        lookup_name = 'GENDER';


-- sqlcl_snapshot {"hash":"0cdbe844cd91ad5175cfa2fe5405f98eab39c65d","type":"VIEW","name":"GENDER","schemaName":"SAMQA","sxml":""}