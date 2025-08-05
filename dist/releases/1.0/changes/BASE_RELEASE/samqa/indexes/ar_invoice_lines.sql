-- liquibase formatted sql
-- changeset SAMQA:1754373929073 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_invoice_lines.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_invoice_lines.sql:null:9a4f1f2bc618ae473afd3c8fe80895d3e7ea10ae:create

create index samqa.ar_invoice_lines on
    samqa.ar_invoice_lines (
        invoice_id,
        status
    );

