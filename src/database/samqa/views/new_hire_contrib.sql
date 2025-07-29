create or replace force editionable view samqa.new_hire_contrib (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'NEW_HIRE_CONTRIB';


-- sqlcl_snapshot {"hash":"33b1a0f7b62ed92371ad7146ae9e2320e6f60104","type":"VIEW","name":"NEW_HIRE_CONTRIB","schemaName":"SAMQA","sxml":""}