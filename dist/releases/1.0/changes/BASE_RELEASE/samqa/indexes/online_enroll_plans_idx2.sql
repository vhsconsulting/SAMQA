-- liquibase formatted sql
-- changeset SAMQA:1754373932383 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_enroll_plans_idx2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_enroll_plans_idx2.sql:null:1865eded0e88067cd30ea22760b970d92a8cb773:create

create index samqa.online_enroll_plans_idx2 on
    samqa.online_enroll_plans (
        ben_plan_id
    );

