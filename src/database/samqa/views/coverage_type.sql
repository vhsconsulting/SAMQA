create or replace force editionable view samqa.coverage_type (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'COVERAGE_TYPE';


-- sqlcl_snapshot {"hash":"0d48233c7b82c864713cccd86c0f3cafbb8b28a4","type":"VIEW","name":"COVERAGE_TYPE","schemaName":"SAMQA","sxml":""}