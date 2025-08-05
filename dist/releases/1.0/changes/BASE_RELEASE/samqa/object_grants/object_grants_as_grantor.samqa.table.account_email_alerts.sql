-- liquibase formatted sql
-- changeset SAMQA:1754373938404 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.account_email_alerts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.account_email_alerts.sql:null:0c1f133c22ee4132083ddb7e8d22d2adb96b4791:create

grant delete on samqa.account_email_alerts to rl_sam_rw;

grant insert on samqa.account_email_alerts to rl_sam_rw;

grant select on samqa.account_email_alerts to rl_sam1_ro;

grant select on samqa.account_email_alerts to rl_sam_rw;

grant select on samqa.account_email_alerts to rl_sam_ro;

grant update on samqa.account_email_alerts to rl_sam_rw;

