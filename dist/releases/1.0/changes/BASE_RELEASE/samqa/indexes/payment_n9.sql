-- liquibase formatted sql
-- changeset SAMQA:1754373932737 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\payment_n9.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/payment_n9.sql:null:a475fb0a0ee39a8507af544b1f50326332430a45:create

create index samqa.payment_n9 on
    samqa.payment (
        plan_type
    );

