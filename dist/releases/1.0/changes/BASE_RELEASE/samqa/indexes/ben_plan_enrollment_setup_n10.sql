-- liquibase formatted sql
-- changeset SAMQA:1754373929461 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_enrollment_setup_n10.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_enrollment_setup_n10.sql:null:4e1e45e3d3e5e08629c79dfc3d4abe3fb9890ba7:create

create index samqa.ben_plan_enrollment_setup_n10 on
    samqa.ben_plan_enrollment_setup (
        product_type
    );

