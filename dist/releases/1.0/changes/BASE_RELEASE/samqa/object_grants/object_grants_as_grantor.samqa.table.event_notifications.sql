-- liquibase formatted sql
-- changeset SAMQA:1754373940383 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.event_notifications.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.event_notifications.sql:null:3e1f949a00122956e2f5985c7ebf15f3377fa637:create

grant delete on samqa.event_notifications to rl_sam_rw;

grant insert on samqa.event_notifications to rl_sam_rw;

grant select on samqa.event_notifications to rl_sam1_ro;

grant select on samqa.event_notifications to rl_sam_rw;

grant select on samqa.event_notifications to rl_sam_ro;

grant update on samqa.event_notifications to rl_sam_rw;

