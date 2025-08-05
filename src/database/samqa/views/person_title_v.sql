create or replace force editionable view samqa.person_title_v (
    lookup_name,
    lookup_code,
    title
) as
    select
        lookup_name,
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'PERSON_TITLE';


-- sqlcl_snapshot {"hash":"692a059c3ff40d64aec850a598f7a4fcfa57b376","type":"VIEW","name":"PERSON_TITLE_V","schemaName":"SAMQA","sxml":""}