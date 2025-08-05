-- liquibase formatted sql
-- changeset SAMQA:1754373930808 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\deposit_register_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/deposit_register_n4.sql:null:2a9730906381b21b0bd54e3f077686f2e3f034cd:create

create index samqa.deposit_register_n4 on
    samqa.deposit_register (
        acc_num
    );

