-- liquibase formatted sql
-- changeset SAMQA:1754373932936 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\plan_fee_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/plan_fee_n2.sql:null:41bab6a60a27485fbb6a454935388e2adb3a98b4:create

create index samqa.plan_fee_n2 on
    samqa.plan_fee (
        fee_code
    );

