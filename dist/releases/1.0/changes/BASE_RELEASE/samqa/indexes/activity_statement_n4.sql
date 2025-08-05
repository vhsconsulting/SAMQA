-- liquibase formatted sql
-- changeset SAMQA:1754373929005 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\activity_statement_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/activity_statement_n4.sql:null:69ed3eec5d0ff40f6b3604ac2281f45bdc3ddf1f:create

create index samqa.activity_statement_n4 on
    samqa.activity_statement (
        acc_num
    );

