-- liquibase formatted sql
-- changeset SAMQA:1754373929081 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_invoice_lines_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_invoice_lines_n1.sql:null:443efa32972d4214f9025fe2f9eff59f0cc521df:create

create index samqa.ar_invoice_lines_n1 on
    samqa.ar_invoice_lines (
        invoice_id,
        invoice_line_type
    );

