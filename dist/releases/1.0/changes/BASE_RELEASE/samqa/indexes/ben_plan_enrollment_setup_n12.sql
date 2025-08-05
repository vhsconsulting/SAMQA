-- liquibase formatted sql
-- changeset SAMQA:1754373929484 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_enrollment_setup_n12.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_enrollment_setup_n12.sql:null:92decc5afbef22ff88c5b701942c21bffd678174:create

create index samqa.ben_plan_enrollment_setup_n12 on
    samqa.ben_plan_enrollment_setup (
        status
    );

