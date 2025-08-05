-- liquibase formatted sql
-- changeset SAMQA:1754373931522 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\file_idx1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/file_idx1.sql:null:fa9fb3ab9274ea0fc6fe074aae9e80c1171c9f2e:create

create index samqa.file_idx1 on
    samqa.files (
        table_name,
        table_id
    );

