-- liquibase formatted sql
-- changeset SAMQA:1754373942036 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.scheduler_calendar.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.scheduler_calendar.sql:null:e0eff2bbf6c47dc5d85a1852c3babc92416cc556:create

grant delete on samqa.scheduler_calendar to rl_sam_rw;

grant insert on samqa.scheduler_calendar to rl_sam_rw;

grant select on samqa.scheduler_calendar to rl_sam1_ro;

grant select on samqa.scheduler_calendar to rl_sam_rw;

grant select on samqa.scheduler_calendar to rl_sam_ro;

grant update on samqa.scheduler_calendar to rl_sam_rw;

