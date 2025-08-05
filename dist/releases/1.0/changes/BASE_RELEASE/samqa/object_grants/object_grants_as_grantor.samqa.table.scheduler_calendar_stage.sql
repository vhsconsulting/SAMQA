-- liquibase formatted sql
-- changeset SAMQA:1754373942044 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.scheduler_calendar_stage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.scheduler_calendar_stage.sql:null:fe286b4d9cea1176804eb21256dbaa6c19ca2a60:create

grant delete on samqa.scheduler_calendar_stage to rl_sam_rw;

grant insert on samqa.scheduler_calendar_stage to rl_sam_rw;

grant select on samqa.scheduler_calendar_stage to rl_sam1_ro;

grant select on samqa.scheduler_calendar_stage to rl_sam_ro;

grant select on samqa.scheduler_calendar_stage to rl_sam_rw;

grant update on samqa.scheduler_calendar_stage to rl_sam_rw;

