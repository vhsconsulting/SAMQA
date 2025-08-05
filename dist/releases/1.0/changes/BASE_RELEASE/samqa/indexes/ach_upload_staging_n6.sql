-- liquibase formatted sql
-- changeset SAMQA:1754373928971 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ach_upload_staging_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ach_upload_staging_n6.sql:null:03062782099fc08bc61d8140dd10792bc3b986d7:create

create index samqa.ach_upload_staging_n6 on
    samqa.ach_upload_staging (
        ssn
    );

