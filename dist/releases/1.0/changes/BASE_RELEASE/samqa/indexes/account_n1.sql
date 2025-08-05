-- liquibase formatted sql
-- changeset SAMQA:1754373928757 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\account_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/account_n1.sql:null:2e05b9682f24addf4771d11e9c520adf97f3e488:create

create index samqa.account_n1 on
    samqa.account (
        account_status
    );

