create or replace force editionable view samqa.relative (
    lookup_name,
    relat_code,
    relat_name
) as
    select
        lookup_name,
        lookup_code relat_code,
        meaning     relat_name
    from
        lookups
    where
        lookup_name = 'RELATIVE';


-- sqlcl_snapshot {"hash":"55dd39117574701163ec651b16a3c9c96ef6a9ca","type":"VIEW","name":"RELATIVE","schemaName":"SAMQA","sxml":""}