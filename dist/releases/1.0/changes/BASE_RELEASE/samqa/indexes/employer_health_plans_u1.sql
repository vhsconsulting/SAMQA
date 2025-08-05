-- liquibase formatted sql
-- changeset SAMQA:1754373931022 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_health_plans_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_health_plans_u1.sql:null:2ac74baf0fb7060aeb03377cb948fb2344b4cb57:create

create index samqa.employer_health_plans_u1 on
    samqa.employer_health_plans (
        health_plan_id
    );

