-- liquibase formatted sql
-- changeset SAMQA:1754373929204 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_invoice_notifications_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_invoice_notifications_n1.sql:null:88f72ed4db5e589a3e9a2c965b4140b8b1667c57:create

create index samqa.ar_invoice_notifications_n1 on
    samqa.ar_invoice_notifications (
        invoice_id
    desc );

