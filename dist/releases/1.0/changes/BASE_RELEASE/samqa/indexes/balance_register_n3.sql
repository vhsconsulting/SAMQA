-- liquibase formatted sql
-- changeset SAMQA:1754373929334 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\balance_register_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/balance_register_n3.sql:null:40ae329e69b73f495d715752d6735cefcfb813b9:create

create index samqa.balance_register_n3 on
    samqa.balance_register (
        change_id,
        reason_mode
    );

