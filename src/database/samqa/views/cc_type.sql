create or replace force editionable view samqa.cc_type (
    lookup_name,
    cc_code,
    cc_name
) as
    select
        lookup_name,
        lookup_code cc_code,
        meaning     cc_name
    from
        lookups
    where
        lookup_name = 'CC_TYPE';


-- sqlcl_snapshot {"hash":"ae271b56ad95a4656c012b89b4af9fbec8b101e5","type":"VIEW","name":"CC_TYPE","schemaName":"SAMQA","sxml":""}