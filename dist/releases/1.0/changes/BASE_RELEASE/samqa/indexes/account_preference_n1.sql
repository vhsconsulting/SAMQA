-- liquibase formatted sql
-- changeset SAMQA:1754373928827 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\account_preference_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/account_preference_n1.sql:null:efd7ed4ca82cf7f1c99c7f52bfe58b2c29832f47:create

create index samqa.account_preference_n1 on
    samqa.account_preference (
        acc_id
    );

