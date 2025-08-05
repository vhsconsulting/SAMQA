-- liquibase formatted sql
-- changeset SAMQA:1754373932391 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_enroll_plans_idx3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_enroll_plans_idx3.sql:null:fcd812aeeeeb216137c048a55dafccfe80d01b09:create

create index samqa.online_enroll_plans_idx3 on
    samqa.online_enroll_plans (
        batch_number
    );

