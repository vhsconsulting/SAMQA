-- liquibase formatted sql
-- changeset SAMQA:1754373929090 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_invoice_lines_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_invoice_lines_n2.sql:null:4e55fd03854ed7aa9689768c8e94313c3f68d1a1:create

create index samqa.ar_invoice_lines_n2 on
    samqa.ar_invoice_lines (
        rate_code
    );

