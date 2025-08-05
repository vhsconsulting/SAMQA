-- liquibase formatted sql
-- changeset SAMQA:1754373933094 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\rate_plan_detail_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/rate_plan_detail_n5.sql:null:d597b048da73dc30866e20414e55710f9ff8f00a:create

create index samqa.rate_plan_detail_n5 on
    samqa.rate_plan_detail (
        effective_date,
        effective_end_date
    );

