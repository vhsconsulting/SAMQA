-- liquibase formatted sql
-- changeset SAMQA:1754373933076 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\rate_plan_detail_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/rate_plan_detail_n3.sql:null:77ad312dea18067fe832d75d6e1abd42f704f250:create

create index samqa.rate_plan_detail_n3 on
    samqa.rate_plan_detail (
        coverage_type
    );

