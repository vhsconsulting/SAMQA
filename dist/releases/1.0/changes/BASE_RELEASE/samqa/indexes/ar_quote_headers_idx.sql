-- liquibase formatted sql
-- changeset SAMQA:1754373929230 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_quote_headers_idx.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_quote_headers_idx.sql:null:6e7eefd2eb63b354714d685f730429f4108e32dd:create

create index samqa.ar_quote_headers_idx on
    samqa.ar_quote_headers (
        ben_plan_id
    );

