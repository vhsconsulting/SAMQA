-- liquibase formatted sql
-- changeset SAMQA:1754373941380 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.notification_template.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.notification_template.sql:null:833cc99cc9e3b10bb79009ff9ccdb4b8402e7f34:create

grant delete on samqa.notification_template to rl_sam_rw;

grant insert on samqa.notification_template to rl_sam_rw;

grant select on samqa.notification_template to rl_sam1_ro;

grant select on samqa.notification_template to rl_sam_rw;

grant select on samqa.notification_template to rl_sam_ro;

grant update on samqa.notification_template to rl_sam_rw;

