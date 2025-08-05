-- liquibase formatted sql
-- changeset SAMQA:1754373941357 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.notification_schedule.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.notification_schedule.sql:null:6d76aae882c717118587144d0d43f8e243026784:create

grant delete on samqa.notification_schedule to rl_sam_rw;

grant insert on samqa.notification_schedule to rl_sam_rw;

grant select on samqa.notification_schedule to rl_sam1_ro;

grant select on samqa.notification_schedule to rl_sam_rw;

grant select on samqa.notification_schedule to rl_sam_ro;

grant update on samqa.notification_schedule to rl_sam_rw;

