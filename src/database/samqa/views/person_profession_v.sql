create or replace force editionable view samqa.person_profession_v (
    profession
) as
    select
        meaning
    from
        lookups
    where
        lookup_name = 'PROFESSION';


-- sqlcl_snapshot {"hash":"5247309fddca6e100de60604cf8b33d84076b1a3","type":"VIEW","name":"PERSON_PROFESSION_V","schemaName":"SAMQA","sxml":""}