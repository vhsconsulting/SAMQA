-- liquibase formatted sql
-- changeset SAMQA:1754373933360 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\scheduler_stage_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/scheduler_stage_n3.sql:null:663caf104405d6a742b21b91e2d9872ef34b83c6:create

create index samqa.scheduler_stage_n3 on
    samqa.scheduler_stage (
        batch_number,
        plan_type
    );

