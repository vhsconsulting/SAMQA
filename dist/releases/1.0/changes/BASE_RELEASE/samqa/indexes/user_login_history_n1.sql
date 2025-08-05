-- liquibase formatted sql
-- changeset SAMQA:1754373933562 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\user_login_history_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/user_login_history_n1.sql:null:8f8f170697b32fc76c511508d3ea2f7fb7ff8f43:create

create index samqa.user_login_history_n1 on
    samqa.user_login_history (
        user_id
    );

