-- liquibase formatted sql
-- changeset SAMQA:1754373929503 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_enrollment_setup_n13.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_enrollment_setup_n13.sql:null:0d9bdaeb5267fa9f4dbba246149a18922b160592:create

create index samqa.ben_plan_enrollment_setup_n13 on
    samqa.ben_plan_enrollment_setup (
        claim_reimbursed_by
    );

