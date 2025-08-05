-- liquibase formatted sql
-- changeset SAMQA:1754373929214 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_invoice_notifications_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_invoice_notifications_n2.sql:null:115f8239469f2f0762fe069f9cba1dd26b4560ef:create

create index samqa.ar_invoice_notifications_n2 on
    samqa.ar_invoice_notifications (
        notification_id
    );

