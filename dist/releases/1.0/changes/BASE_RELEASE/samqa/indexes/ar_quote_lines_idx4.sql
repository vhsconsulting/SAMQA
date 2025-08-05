-- liquibase formatted sql
-- changeset SAMQA:1754373929288 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_quote_lines_idx4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_quote_lines_idx4.sql:null:443eb976caec42d035ef629097965cee2958f987:create

create index samqa.ar_quote_lines_idx4 on
    samqa.ar_quote_lines (
        rate_plan_detail_id
    );

