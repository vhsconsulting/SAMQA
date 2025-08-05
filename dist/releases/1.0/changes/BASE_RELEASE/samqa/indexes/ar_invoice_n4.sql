-- liquibase formatted sql
-- changeset SAMQA:1754373929140 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_invoice_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_invoice_n4.sql:null:93b869884bccaea124cf4a7ef69e49db9e53a367:create

create index samqa.ar_invoice_n4 on
    samqa.ar_invoice (
        bank_acct_id
    );

