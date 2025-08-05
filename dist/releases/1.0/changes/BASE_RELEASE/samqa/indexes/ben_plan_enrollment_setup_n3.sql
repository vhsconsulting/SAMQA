-- liquibase formatted sql
-- changeset SAMQA:1754373929533 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_enrollment_setup_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_enrollment_setup_n3.sql:null:05440aae11dac8268f7e737c18bc73d576aea42e:create

create index samqa.ben_plan_enrollment_setup_n3 on
    samqa.ben_plan_enrollment_setup (
        acc_id,
        plan_start_date,
        plan_end_date
    );

