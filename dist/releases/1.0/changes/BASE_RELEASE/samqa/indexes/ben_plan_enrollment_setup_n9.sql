-- liquibase formatted sql
-- changeset SAMQA:1754373929598 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_enrollment_setup_n9.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_enrollment_setup_n9.sql:null:41c26e4589e3b276083a9c98b12f745e5f99941f:create

create index samqa.ben_plan_enrollment_setup_n9 on
    samqa.ben_plan_enrollment_setup (
        plan_type
    );

