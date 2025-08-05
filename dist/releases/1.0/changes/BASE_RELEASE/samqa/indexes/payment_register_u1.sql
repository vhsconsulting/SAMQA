-- liquibase formatted sql
-- changeset SAMQA:1754373932807 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\payment_register_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/payment_register_u1.sql:null:a1bf44aa5a7d6c800944d8d54f5bec909d45a19a:create

create index samqa.payment_register_u1 on
    samqa.payment_register (
        payment_register_id
    );

