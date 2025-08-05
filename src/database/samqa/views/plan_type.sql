create or replace force editionable view samqa.plan_type (
    plan_type_code,
    plan_name,
    plan_type
) as
    select
        lookup_code plan_type_code,
        meaning     plan_name,
        description plan_type
    from
        lookups
    where
        lookup_name = 'PLAN_TYPE';


-- sqlcl_snapshot {"hash":"0672b5e9bae30755ee32fd80410abfc46ed99074","type":"VIEW","name":"PLAN_TYPE","schemaName":"SAMQA","sxml":""}