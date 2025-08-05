-- liquibase formatted sql
-- changeset SAMQA:1754373939206 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.carrier_notification.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.carrier_notification.sql:null:03706d82a6e19bb0fa70d35974d2875643d86dc1:create

grant delete on samqa.carrier_notification to rl_sam_rw;

grant delete on samqa.carrier_notification to public;

grant insert on samqa.carrier_notification to public;

grant insert on samqa.carrier_notification to rl_sam_rw;

grant select on samqa.carrier_notification to rl_sam1_ro;

grant select on samqa.carrier_notification to public;

grant select on samqa.carrier_notification to rl_sam_ro;

grant select on samqa.carrier_notification to rl_sam_rw;

grant update on samqa.carrier_notification to public;

grant update on samqa.carrier_notification to rl_sam_rw;

