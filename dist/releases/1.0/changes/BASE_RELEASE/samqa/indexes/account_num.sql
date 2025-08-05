-- liquibase formatted sql
-- changeset SAMQA:1754373928819 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\account_num.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/account_num.sql:null:7b1ffbffcb545552338bf981a53879f35fdee8ef:create

create unique index samqa.account_num on
    samqa.account (
        acc_num
    );

