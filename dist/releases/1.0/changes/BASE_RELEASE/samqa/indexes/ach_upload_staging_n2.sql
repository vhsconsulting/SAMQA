-- liquibase formatted sql
-- changeset SAMQA:1754373928937 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ach_upload_staging_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ach_upload_staging_n2.sql:null:58c2f9f3fb33ea9c9181979de9985fc8e1d9927d:create

create index samqa.ach_upload_staging_n2 on
    samqa.ach_upload_staging (
        transaction_id
    );

