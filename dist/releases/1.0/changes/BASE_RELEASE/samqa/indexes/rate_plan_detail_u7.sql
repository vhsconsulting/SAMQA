-- liquibase formatted sql
-- changeset SAMQA:1754373933101 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\rate_plan_detail_u7.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/rate_plan_detail_u7.sql:null:7c3bbd6f818e502c65b3f19f437e29318033d55a:create

create index samqa.rate_plan_detail_u7 on
    samqa.rate_plan_detail (
        plan_id
    );

