-- liquibase formatted sql
-- changeset SAMQA:1754373929585 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_enrollment_setup_n8.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_enrollment_setup_n8.sql:null:5f71d3a9326c9906f0c7743d5648482c054e8040:create

create index samqa.ben_plan_enrollment_setup_n8 on
    samqa.ben_plan_enrollment_setup (
        ben_plan_id_main
    );

