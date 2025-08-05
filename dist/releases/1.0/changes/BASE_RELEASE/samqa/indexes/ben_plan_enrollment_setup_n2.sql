-- liquibase formatted sql
-- changeset SAMQA:1754373929516 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_enrollment_setup_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_enrollment_setup_n2.sql:null:cb777828c9cb937e7d1a4b77ed1c4c251f94474d:create

create index samqa.ben_plan_enrollment_setup_n2 on
    samqa.ben_plan_enrollment_setup (
        acc_id,
        plan_type,
        status
    );

