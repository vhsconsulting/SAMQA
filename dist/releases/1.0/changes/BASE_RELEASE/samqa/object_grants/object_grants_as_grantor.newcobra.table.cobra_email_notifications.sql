-- liquibase formatted sql
-- changeset SAMQA:1754373926137 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.table.cobra_email_notifications.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.table.cobra_email_notifications.sql:null:a931cb46e80bad36308f99b34939cdc335b6ae44:create

grant alter on newcobra.cobra_email_notifications to samqa;

grant delete on newcobra.cobra_email_notifications to samqa;

grant index on newcobra.cobra_email_notifications to samqa;

grant insert on newcobra.cobra_email_notifications to samqa;

grant select on newcobra.cobra_email_notifications to samqa;

grant update on newcobra.cobra_email_notifications to samqa;

grant references on newcobra.cobra_email_notifications to samqa;

grant read on newcobra.cobra_email_notifications to samqa;

grant on commit refresh on newcobra.cobra_email_notifications to samqa;

grant query rewrite on newcobra.cobra_email_notifications to samqa;

grant debug on newcobra.cobra_email_notifications to samqa;

grant flashback on newcobra.cobra_email_notifications to samqa;

