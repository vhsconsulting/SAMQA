-- liquibase formatted sql
-- changeset SAMQA:1754373941008 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.map_notification_events.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.map_notification_events.sql:null:0744f51bf8a17a56c12e2d75b431258debb046ef:create

grant alter on samqa.map_notification_events to public;

grant delete on samqa.map_notification_events to rl_sam_rw;

grant delete on samqa.map_notification_events to public;

grant index on samqa.map_notification_events to public;

grant insert on samqa.map_notification_events to rl_sam_rw;

grant insert on samqa.map_notification_events to public;

grant select on samqa.map_notification_events to rl_sam_ro;

grant select on samqa.map_notification_events to rl_sam_rw;

grant select on samqa.map_notification_events to rl_sam1_ro;

grant select on samqa.map_notification_events to public;

grant update on samqa.map_notification_events to rl_sam_rw;

grant update on samqa.map_notification_events to public;

grant references on samqa.map_notification_events to public;

grant read on samqa.map_notification_events to public;

grant on commit refresh on samqa.map_notification_events to public;

grant query rewrite on samqa.map_notification_events to public;

grant debug on samqa.map_notification_events to public;

grant flashback on samqa.map_notification_events to public;

