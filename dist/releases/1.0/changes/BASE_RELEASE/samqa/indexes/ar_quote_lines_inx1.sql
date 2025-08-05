-- liquibase formatted sql
-- changeset SAMQA:1754373929299 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_quote_lines_inx1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_quote_lines_inx1.sql:null:e372b1f43cd242b8daf34d98f632674c68a1929b:create

create index samqa.ar_quote_lines_inx1 on
    samqa.ar_quote_lines (
        quote_line_id
    );

