-- liquibase formatted sql
-- changeset SAMQA:1754373933352 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\scheduler_stage_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/scheduler_stage_n2.sql:null:d6c631d57fc00a42725b79ed665d659751655780:create

create index samqa.scheduler_stage_n2 on
    samqa.scheduler_stage (
        batch_number
    );

