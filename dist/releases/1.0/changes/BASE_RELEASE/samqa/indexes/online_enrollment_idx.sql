-- liquibase formatted sql
-- changeset SAMQA:1754373932401 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_enrollment_idx.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_enrollment_idx.sql:null:ac9d9665123c051d31e0310f5b72bf628670c33b:create

create index samqa.online_enrollment_idx on
    samqa.online_enrollment (
        batch_number
    );

