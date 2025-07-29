create or replace force editionable view samqa.us_states (
    lookup_name,
    state_abbr,
    state_name
) as
    select
        lookup_name,
        lookup_code state_abbr,
        meaning     state_name
    from
        lookups
    where
        lookup_name = 'STATE';


-- sqlcl_snapshot {"hash":"fa56b362479f45ce0c5e2b27d01c4848173d48e2","type":"VIEW","name":"US_STATES","schemaName":"SAMQA","sxml":""}