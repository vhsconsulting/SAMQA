-- liquibase formatted sql
-- changeset SAMQA:1754373929562 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_enrollment_setup_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_enrollment_setup_n6.sql:null:6bbbe3cc9a69be4e068ca57f9d30c629e71bcaaa:create

create index samqa.ben_plan_enrollment_setup_n6 on
    samqa.ben_plan_enrollment_setup (
        acc_id,
        plan_type,
    trunc(plan_start_date),
    trunc(plan_end_date) );

