-- liquibase formatted sql
-- changeset SAMQA:1754373929097 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_invoice_lines_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_invoice_lines_n3.sql:null:986fdefcd75103e4572a5160982de26863af1392:create

create index samqa.ar_invoice_lines_n3 on
    samqa.ar_invoice_lines (
        batch_number
    );

