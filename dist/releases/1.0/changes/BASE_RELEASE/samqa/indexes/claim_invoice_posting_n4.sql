-- liquibase formatted sql
-- changeset SAMQA:1754373930352 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_invoice_posting_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_invoice_posting_n4.sql:null:37b578287ebf4142d19d08762aa40aef6e6fa74e:create

create index samqa.claim_invoice_posting_n4 on
    samqa.claim_invoice_posting (
        transaction_id
    );

