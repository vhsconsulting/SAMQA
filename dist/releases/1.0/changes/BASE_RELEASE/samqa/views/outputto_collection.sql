-- liquibase formatted sql
-- changeset SAMQA:1754374177722 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\outputto_collection.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/outputto_collection.sql:null:79572a10f64245e36d60d0baaec7f71b8ebfdd84:create

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

