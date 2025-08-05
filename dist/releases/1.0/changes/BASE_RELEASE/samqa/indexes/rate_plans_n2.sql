-- liquibase formatted sql
-- changeset SAMQA:1754373933122 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\rate_plans_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/rate_plans_n2.sql:null:8070b7eb7d02d78d15218a55525940b7521ca4e7:create

create index samqa.rate_plans_n2 on
    samqa.rate_plans (
        rate_plan_type
    );

