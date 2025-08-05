-- liquibase formatted sql
-- changeset SAMQA:1754373929453 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_enrollment_setup_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_enrollment_setup_n1.sql:null:b69f75d627f57ad7f488c0c22bb7fa75c41f1259:create

create index samqa.ben_plan_enrollment_setup_n1 on
    samqa.ben_plan_enrollment_setup (
        acc_id
    );

