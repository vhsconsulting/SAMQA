-- liquibase formatted sql
-- changeset SAMQA:1754373928843 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\account_type_n7.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/account_type_n7.sql:null:5865aabe8043962ad31e9bda248bf1eaa130ad8d:create

create index samqa.account_type_n7 on
    samqa.account (
        account_type
    );

