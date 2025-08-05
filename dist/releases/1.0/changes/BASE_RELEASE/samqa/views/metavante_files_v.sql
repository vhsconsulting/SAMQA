-- liquibase formatted sql
-- changeset SAMQA:1754374176851 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\metavante_files_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/metavante_files_v.sql:null:757e8bba50d9bb78abe5cc9448be67fa042b9b60:create

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

