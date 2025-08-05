-- liquibase formatted sql
-- changeset SAMQA:1754373929361 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\balance_register_v2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/balance_register_v2.sql:null:7b17ddf74b59c5399925ef998027bb8cd66e09d9:create

create index samqa.balance_register_v2 on
    samqa.balance_register (
        txn_date
    );

