-- liquibase formatted sql
-- changeset SAMQA:1754373931937 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\mass_enroll_plans_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/mass_enroll_plans_n2.sql:null:5d46e1178c49b7a46028ddccd94a61f5b6c6272d:create

create index samqa.mass_enroll_plans_n2 on
    samqa.mass_enroll_plans (
        ben_plan_id
    );

