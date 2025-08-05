create or replace force editionable view samqa.id_type (
    id_type,
    id_type_name
) as
    select
        lookup_code id_type,
        meaning     id_type_name
    from
        lookups
    where
        lookup_name = 'ID_TYPE';


-- sqlcl_snapshot {"hash":"1afda307b93320c55947659c29a82c2aca80b678","type":"VIEW","name":"ID_TYPE","schemaName":"SAMQA","sxml":""}