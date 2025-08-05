-- liquibase formatted sql
-- changeset SAMQA:1754373931344 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\enterprise_idx1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/enterprise_idx1.sql:null:d7e5d239329ad8e2eda065cc4352b215d5c93e53:create

create index samqa.enterprise_idx1 on
    samqa.enterprise (
        name,
        en_code
    );

