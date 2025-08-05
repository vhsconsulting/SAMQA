-- liquibase formatted sql
-- changeset SAMQA:1754373929265 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_quote_lines_idx.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_quote_lines_idx.sql:null:4a76b5c7d10eead90a4bbb793c6371607f6ceb3d:create

create index samqa.ar_quote_lines_idx on
    samqa.ar_quote_lines (
        quote_header_id
    );

