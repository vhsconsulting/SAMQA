-- liquibase formatted sql
-- changeset SAMQA:1754373929343 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\balance_register_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/balance_register_n5.sql:null:c17e4931565ad6eb872f181d7b4f9f6bbd155057:create

create index samqa.balance_register_n5 on
    samqa.balance_register (
        reason_mode
    );

