-- liquibase formatted sql
-- changeset SAMQA:1754373939851 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.email_notifications.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.email_notifications.sql:null:269edfe43ae7a6e63958f268da78d3628bd3b813:create

grant delete on samqa.email_notifications to rl_sam_rw;

grant insert on samqa.email_notifications to rl_sam_rw;

grant select on samqa.email_notifications to rl_sam1_ro;

grant select on samqa.email_notifications to rl_sam_rw;

grant select on samqa.email_notifications to rl_sam_ro;

grant update on samqa.email_notifications to rl_sam_rw;

