create or replace force editionable view samqa.en_type (
    lookup_name,
    en_code,
    en_name
) as
    select
        lookup_name,
        lookup_code en_code,
        meaning     en_name
    from
        lookups
    where
        lookup_name = 'EN_TYPE';


-- sqlcl_snapshot {"hash":"23fde6b642a826990653b7ead9e327385be5ab58","type":"VIEW","name":"EN_TYPE","schemaName":"SAMQA","sxml":""}