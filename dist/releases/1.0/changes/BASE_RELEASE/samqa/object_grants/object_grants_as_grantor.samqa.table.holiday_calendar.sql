-- liquibase formatted sql
-- changeset SAMQA:1754373940702 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.holiday_calendar.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.holiday_calendar.sql:null:c3371794edc8695ac7c67dcaa883721cc21ca6bd:create

grant delete on samqa.holiday_calendar to rl_sam_rw;

grant insert on samqa.holiday_calendar to rl_sam_rw;

grant select on samqa.holiday_calendar to rl_sam1_ro;

grant select on samqa.holiday_calendar to rl_sam_rw;

grant select on samqa.holiday_calendar to rl_sam_ro;

grant update on samqa.holiday_calendar to rl_sam_rw;

