create or replace force editionable view samqa.outputto_collection (
    id,
    filename,
    mimetype,
    file_content
) as
    select
        seq_id  id,
        c001    filename,
        c002    mimetype,
        blob001 file_content
    from
        apex_collections
    where
        collection_name = 'OUTPUTTO_COLLECTION';


-- sqlcl_snapshot {"hash":"79572a10f64245e36d60d0baaec7f71b8ebfdd84","type":"VIEW","name":"OUTPUTTO_COLLECTION","schemaName":"SAMQA","sxml":""}