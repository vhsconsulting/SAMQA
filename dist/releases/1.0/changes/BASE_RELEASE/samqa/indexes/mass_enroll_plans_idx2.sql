-- liquibase formatted sql
-- changeset SAMQA:1754373931922 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\mass_enroll_plans_idx2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/mass_enroll_plans_idx2.sql:null:ede49a42a5a982e06a11ec6a40b8de43c317b58a:create

create index samqa.mass_enroll_plans_idx2 on
    samqa.mass_enroll_plans (
        batch_number
    );

