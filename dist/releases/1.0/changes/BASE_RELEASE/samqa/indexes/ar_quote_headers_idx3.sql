-- liquibase formatted sql
-- changeset SAMQA:1754373929241 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_quote_headers_idx3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_quote_headers_idx3.sql:null:b316e1d20208eae766a1f59587e7724977c75e42:create

create index samqa.ar_quote_headers_idx3 on
    samqa.ar_quote_headers (
        entrp_id
    );

