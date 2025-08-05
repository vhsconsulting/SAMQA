create or replace force editionable view samqa.person_type (
    person_type,
    meaning
) as
    select
        lookup_code person_type,
        description meaning
    from
        lookups
    where
        lookup_name = 'PERSON_TYPE';


-- sqlcl_snapshot {"hash":"4291fb9bc3e1fd8a6a3d6004929d709f3450b9a5","type":"VIEW","name":"PERSON_TYPE","schemaName":"SAMQA","sxml":""}