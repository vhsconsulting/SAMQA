-- liquibase formatted sql
-- changeset SAMQA:1754373931477 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\external_files_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/external_files_n1.sql:null:7eaf803cdb59b8b5c409ce84a0066f242b9b33d7:create

create index samqa.external_files_n1 on
    samqa.external_files (
        file_id,
        file_action,
        creation_date,
        result_flag
    );

