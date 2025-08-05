-- liquibase formatted sql
-- changeset SAMQA:1754373929106 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_invoice_lines_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_invoice_lines_n4.sql:null:22d3fb3479328017f29faf2c5db08265664ea791:create

create index samqa.ar_invoice_lines_n4 on
    samqa.ar_invoice_lines (
        status
    );

