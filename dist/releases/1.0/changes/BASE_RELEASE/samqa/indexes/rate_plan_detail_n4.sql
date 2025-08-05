-- liquibase formatted sql
-- changeset SAMQA:1754373933085 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\rate_plan_detail_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/rate_plan_detail_n4.sql:null:177ad1235f3c7c219566d7147e690e489fb8b646:create

create index samqa.rate_plan_detail_n4 on
    samqa.rate_plan_detail (
        rate_plan_id,
        rate_code
    );

