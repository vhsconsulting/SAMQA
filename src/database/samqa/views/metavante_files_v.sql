create or replace force editionable view samqa.metavante_files_v (
    file_code,
    file_action
) as
    select
        lookup_code file_code,
        description file_action
    from
        lookups
    where
        lookup_name = 'MBI_FILES';


-- sqlcl_snapshot {"hash":"757e8bba50d9bb78abe5cc9448be67fa042b9b60","type":"VIEW","name":"METAVANTE_FILES_V","schemaName":"SAMQA","sxml":""}