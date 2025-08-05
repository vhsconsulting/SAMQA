-- liquibase formatted sql
-- changeset SAMQA:1754373931914 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\mass_enroll_plans_idx.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/mass_enroll_plans_idx.sql:null:74c8ed28435d14968258cd8899733e72dd607a39:create

create index samqa.mass_enroll_plans_idx on
    samqa.mass_enroll_plans (
        mass_enrollment_id
    );

