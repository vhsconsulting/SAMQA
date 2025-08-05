-- liquibase formatted sql
-- changeset SAMQA:1754373932539 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_users_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_users_n1.sql:null:1bfb1244eb1bf90e0b0e25b52737dde418365911:create

create index samqa.online_users_n1 on
    samqa.online_users (
        find_key
    );

