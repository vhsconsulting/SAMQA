-- liquibase formatted sql
-- changeset SAMQA:1754373931945 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\mass_enroll_plans_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/mass_enroll_plans_n3.sql:null:5041c502747a38bb22b8e68a7306578c6f8cd192:create

create index samqa.mass_enroll_plans_n3 on
    samqa.mass_enroll_plans (
        effective_date,
        plan_type
    );

