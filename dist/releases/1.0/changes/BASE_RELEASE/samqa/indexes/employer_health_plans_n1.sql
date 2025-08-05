-- liquibase formatted sql
-- changeset SAMQA:1754373931005 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_health_plans_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_health_plans_n1.sql:null:9f94c1934d42b3bbed1dd95a49e11c849c17bbc9:create

create index samqa.employer_health_plans_n1 on
    samqa.employer_health_plans (
        health_plan_id,
        entrp_id
    );

