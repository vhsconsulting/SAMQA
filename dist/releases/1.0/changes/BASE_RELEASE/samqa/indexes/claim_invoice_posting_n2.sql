-- liquibase formatted sql
-- changeset SAMQA:1754373930333 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_invoice_posting_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_invoice_posting_n2.sql:null:d02de3b190258e47c95dc458a2b59d14c4e0ff90:create

create index samqa.claim_invoice_posting_n2 on
    samqa.claim_invoice_posting (
        invoice_id
    );

