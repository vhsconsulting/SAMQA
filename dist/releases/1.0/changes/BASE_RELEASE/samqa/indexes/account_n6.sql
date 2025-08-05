-- liquibase formatted sql
-- changeset SAMQA:1754373928790 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\account_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/account_n6.sql:null:232bd1eff8cfb610268c76a04ebee4d2c7e89438:create

create index samqa.account_n6 on
    samqa.account (
        broker_id
    );

