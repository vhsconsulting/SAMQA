create or replace force editionable view samqa.insurance_category (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'INSURANCE_CATEGORY';


-- sqlcl_snapshot {"hash":"beecaaf81cde5a117d78e36ae77fd671a1351af7","type":"VIEW","name":"INSURANCE_CATEGORY","schemaName":"SAMQA","sxml":""}