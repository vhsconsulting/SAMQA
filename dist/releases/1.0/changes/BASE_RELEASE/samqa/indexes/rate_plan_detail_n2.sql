-- liquibase formatted sql
-- changeset SAMQA:1754373933063 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\rate_plan_detail_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/rate_plan_detail_n2.sql:null:e5a255deecbdfa9f879e3ed23bf2573d88d9bdf7:create

create index samqa.rate_plan_detail_n2 on
    samqa.rate_plan_detail (
        rate_plan_id
    );

