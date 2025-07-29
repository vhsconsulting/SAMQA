create or replace force editionable view samqa.ben_plan_status (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'BEN_PLAN_STATUS';


-- sqlcl_snapshot {"hash":"efab44d657ffc3a477e2f5c293707e687e2dc6ea","type":"VIEW","name":"BEN_PLAN_STATUS","schemaName":"SAMQA","sxml":""}