-- liquibase formatted sql
-- changeset SAMQA:1754373929021 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_invoice_contacts_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_invoice_contacts_n1.sql:null:8b81c407a5ac059a2b58ce5f8af1109618d560fe:create

create index samqa.ar_invoice_contacts_n1 on
    samqa.ar_invoice_contacts (
        invoice_id
    );

