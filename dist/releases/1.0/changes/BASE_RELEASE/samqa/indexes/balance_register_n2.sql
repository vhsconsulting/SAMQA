-- liquibase formatted sql
-- changeset SAMQA:1754373929322 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\balance_register_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/balance_register_n2.sql:null:28970be337be0d4af91730881515aeb719d8fd02:create

create index samqa.balance_register_n2 on
    samqa.balance_register (
        acc_id,
        reason_mode,
        fee_date
    );

