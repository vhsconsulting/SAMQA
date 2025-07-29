create or replace force editionable view samqa.fsa_plan_type (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'FSA_PLAN_TYPE';


-- sqlcl_snapshot {"hash":"856df9d15b4c6ffe11f12b0b39e858b7b20b8c77","type":"VIEW","name":"FSA_PLAN_TYPE","schemaName":"SAMQA","sxml":""}