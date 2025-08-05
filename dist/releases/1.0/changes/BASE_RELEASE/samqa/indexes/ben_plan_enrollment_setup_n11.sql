-- liquibase formatted sql
-- changeset SAMQA:1754373929470 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_enrollment_setup_n11.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_enrollment_setup_n11.sql:null:2eeb04e13dca739666f67df1006d4958648cf357:create

create index samqa.ben_plan_enrollment_setup_n11 on
    samqa.ben_plan_enrollment_setup (
        funding_options
    );

