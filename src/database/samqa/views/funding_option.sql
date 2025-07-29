create or replace force editionable view samqa.funding_option (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'FUNDING_OPTION';


-- sqlcl_snapshot {"hash":"f72f85e48a97ff1dc662286ff3e21dae1fd5c263","type":"VIEW","name":"FUNDING_OPTION","schemaName":"SAMQA","sxml":""}