-- liquibase formatted sql
-- changeset SAMQA:1754373942192 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.sms_notifications.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.sms_notifications.sql:null:22d94d40552ec1e5fe2b725fada873fd86106e24:create

grant alter on samqa.sms_notifications to public;

grant delete on samqa.sms_notifications to public;

grant delete on samqa.sms_notifications to rl_sam_rw;

grant index on samqa.sms_notifications to public;

grant insert on samqa.sms_notifications to public;

grant insert on samqa.sms_notifications to rl_sam_rw;

grant select on samqa.sms_notifications to rl_sam1_ro;

grant select on samqa.sms_notifications to public;

grant select on samqa.sms_notifications to rl_sam_ro;

grant select on samqa.sms_notifications to rl_sam_rw;

grant update on samqa.sms_notifications to public;

grant update on samqa.sms_notifications to rl_sam_rw;

grant references on samqa.sms_notifications to public;

grant read on samqa.sms_notifications to public;

grant on commit refresh on samqa.sms_notifications to public;

grant query rewrite on samqa.sms_notifications to public;

grant debug on samqa.sms_notifications to public;

grant flashback on samqa.sms_notifications to public;

