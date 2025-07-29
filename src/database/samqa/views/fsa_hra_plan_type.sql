create or replace force editionable view samqa.fsa_hra_plan_type (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'FSA_HRA_PLAN_TYPE'
    union
    select
        lookup_code,
        meaning
    from
        lookups
    where
            lookup_name = 'FSA_PLAN_TYPE'
        and lookup_code <> 'HRA';


-- sqlcl_snapshot {"hash":"060d2863b54865c08eefbf71bba3cc296a35b300","type":"VIEW","name":"FSA_HRA_PLAN_TYPE","schemaName":"SAMQA","sxml":""}