-- liquibase formatted sql
-- changeset SAMQA:1754373931929 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\mass_enroll_plans_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/mass_enroll_plans_n1.sql:null:b502d6823469545ad40b1a7ed86a85342250f5a2:create

create index samqa.mass_enroll_plans_n1 on
    samqa.mass_enroll_plans (
        er_ben_plan_id
    );

