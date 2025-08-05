-- liquibase formatted sql
-- changeset SAMQA:1754373928835 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\account_preference_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/account_preference_n2.sql:null:cb612f1cd689a31051f9fb4197dc8a1a2c6a69cb:create

create index samqa.account_preference_n2 on
    samqa.account_preference (
        entrp_id
    );

