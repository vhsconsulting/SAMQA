-- liquibase formatted sql
-- changeset SAMQA:1754373929351 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\balance_register_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/balance_register_n6.sql:null:8f80e44494c30b5fc9aa956d44f2bae102736ab8:create

create index samqa.balance_register_n6 on
    samqa.balance_register (
        reason_mode,
        plan_type
    );

