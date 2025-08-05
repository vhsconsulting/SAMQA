-- liquibase formatted sql
-- changeset SAMQA:1754373929277 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_quote_lines_idx3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_quote_lines_idx3.sql:null:2437eae90f714e05d2e05f7012caa63f9ab4cc36:create

create index samqa.ar_quote_lines_idx3 on
    samqa.ar_quote_lines (
        rate_plan_id
    );

