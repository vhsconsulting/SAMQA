-- liquibase formatted sql
-- changeset SAMQA:1754373940801 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.incident_notifications.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.incident_notifications.sql:null:d183b80f0c4cb61826a1828a67cf2a6789fe464e:create

grant delete on samqa.incident_notifications to rl_sam_rw;

grant insert on samqa.incident_notifications to rl_sam_rw;

grant select on samqa.incident_notifications to smareedu;

grant select on samqa.incident_notifications to rl_sam_ro;

