-- liquibase formatted sql
-- changeset SAMQA:1754373939215 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.carrier_notification_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.carrier_notification_staging.sql:null:1a751fa3fe6d2db30f8526a4b17d4504ba967a96:create

grant delete on samqa.carrier_notification_staging to rl_sam_rw;

grant insert on samqa.carrier_notification_staging to rl_sam_rw;

grant select on samqa.carrier_notification_staging to rl_sam1_ro;

grant select on samqa.carrier_notification_staging to rl_sam_ro;

grant select on samqa.carrier_notification_staging to rl_sam_rw;

grant update on samqa.carrier_notification_staging to rl_sam_rw;

