-- liquibase formatted sql
-- changeset SAMQA:1754373929546 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_enrollment_setup_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_enrollment_setup_n5.sql:null:ce600e828faea589e943f3260aad56882046e379:create

create index samqa.ben_plan_enrollment_setup_n5 on
    samqa.ben_plan_enrollment_setup (
        acc_id,
        plan_type,
        plan_start_date,
        plan_end_date
    );

