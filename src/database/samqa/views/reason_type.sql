create or replace force editionable view samqa.reason_type (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'REASON_TYPE';


-- sqlcl_snapshot {"hash":"e3060f10ddf6573c060a6f6f28b69d547159c634","type":"VIEW","name":"REASON_TYPE","schemaName":"SAMQA","sxml":""}