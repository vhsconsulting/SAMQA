create or replace force editionable view samqa.term_eligibility (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'TERM_ELIGIBILITY';


-- sqlcl_snapshot {"hash":"fc12f65bed730924a001106fb377d5ec29e1fdd0","type":"VIEW","name":"TERM_ELIGIBILITY","schemaName":"SAMQA","sxml":""}