-- liquibase formatted sql
-- changeset SAMQA:1754373930341 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_invoice_posting_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_invoice_posting_n3.sql:null:4af1c04696cadb6456cef5f7fa43d9341d7e7ab7:create

create index samqa.claim_invoice_posting_n3 on
    samqa.claim_invoice_posting (
        change_num
    );

