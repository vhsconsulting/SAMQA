create or replace force editionable view samqa.funding_type (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'FUNDING_TYPE';


-- sqlcl_snapshot {"hash":"e764b97faaa2e314af83f04aa36df39121550a53","type":"VIEW","name":"FUNDING_TYPE","schemaName":"SAMQA","sxml":""}