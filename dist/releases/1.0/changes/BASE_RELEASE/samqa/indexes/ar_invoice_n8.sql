-- liquibase formatted sql
-- changeset SAMQA:1754373929190 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_invoice_n8.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_invoice_n8.sql:null:73c455c0cae3c3644622671690e1b966515ca4a7:create

create index samqa.ar_invoice_n8 on
    samqa.ar_invoice (
        plan_type
    );

