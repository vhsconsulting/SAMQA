create or replace force editionable view samqa.enrollment_source (
    source_code,
    meaning
) as
    select
        lookup_code source_code,
        meaning     gender
    from
        lookups
    where
        lookup_name = 'ENROLLMENT_SOURCE';


-- sqlcl_snapshot {"hash":"ad94ef7963dbb799a400672e5d2f36882e3a2357","type":"VIEW","name":"ENROLLMENT_SOURCE","schemaName":"SAMQA","sxml":""}