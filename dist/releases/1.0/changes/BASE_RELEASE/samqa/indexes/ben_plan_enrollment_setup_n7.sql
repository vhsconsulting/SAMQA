-- liquibase formatted sql
-- changeset SAMQA:1754373929572 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_enrollment_setup_n7.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_enrollment_setup_n7.sql:null:345152e038cefd8e0816fbd82d8b6a0904f007e0:create

create index samqa.ben_plan_enrollment_setup_n7 on
    samqa.ben_plan_enrollment_setup (
        entrp_id
    );

