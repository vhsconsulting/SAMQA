-- liquibase formatted sql
-- changeset SAMQA:1754373929252 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_quote_headers_idx4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_quote_headers_idx4.sql:null:6eb759dd6c3b39765917d3488073dab289d2b11a:create

create index samqa.ar_quote_headers_idx4 on
    samqa.ar_quote_headers (
        batch_number
    );

