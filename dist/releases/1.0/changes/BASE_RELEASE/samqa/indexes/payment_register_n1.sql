-- liquibase formatted sql
-- changeset SAMQA:1754373932745 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\payment_register_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/payment_register_n1.sql:null:5e346ad02bd419740a332d8ad90b23ac340ca23f:create

create index samqa.payment_register_n1 on
    samqa.payment_register (
        batch_number
    );

