-- liquibase formatted sql
-- changeset SAMQA:1754373929032 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_invoice_contacts_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_invoice_contacts_n2.sql:null:4cbe7ec5503f7bbd1af3ad6f6f42606ee06afd6d:create

create index samqa.ar_invoice_contacts_n2 on
    samqa.ar_invoice_contacts (
        contact_id
    );

