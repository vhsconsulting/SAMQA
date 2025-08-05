-- liquibase formatted sql
-- changeset SAMQA:1754373929612 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_enrollment_setup_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_enrollment_setup_u1.sql:null:52debfe7247d9e650b269de6cdf12ac225d5c587:create

create unique index samqa.ben_plan_enrollment_setup_u1 on
    samqa.ben_plan_enrollment_setup (
        ben_plan_id
    );

