-- liquibase formatted sql
-- changeset SAMQA:1754373941357 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.notif_participants.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.notif_participants.sql:null:d60188b6b9a31e7302a61b517303757ca44adb72:create

grant delete on samqa.notif_participants to rl_sam_rw;

grant insert on samqa.notif_participants to rl_sam_rw;

grant select on samqa.notif_participants to rl_sam1_ro;

grant select on samqa.notif_participants to rl_sam_rw;

grant select on samqa.notif_participants to rl_sam_ro;

grant update on samqa.notif_participants to rl_sam_rw;

