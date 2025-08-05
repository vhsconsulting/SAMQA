-- liquibase formatted sql
-- changeset SAMQA:1754373933562 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\user_login_history_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/user_login_history_n2.sql:null:b8513393bac652cd0a7d6c57c7b34b0fc1e5ef46:create

create index samqa.user_login_history_n2 on
    samqa.user_login_history (
        user_name
    );

