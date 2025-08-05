-- liquibase formatted sql
-- changeset SAMQA:1754373932763 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\payment_register_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/payment_register_n3.sql:null:8d6d0c42701671dd3fb275ee890665282b39c227:create

create index samqa.payment_register_n3 on
    samqa.payment_register (
        vendor_id
    );

