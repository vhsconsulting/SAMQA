-- liquibase formatted sql
-- changeset SAMQA:1754373936234 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_incident_notifications.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_incident_notifications.sql:null:0f0aa5409eae275496397e3a8ce8fdd32cab2ef5:create

grant execute on samqa.pc_incident_notifications to rl_sam_ro;

grant debug on samqa.pc_incident_notifications to rl_sam_ro;

