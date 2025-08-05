-- liquibase formatted sql
-- changeset SAMQA:1754373940769 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.incident_attachments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.incident_attachments.sql:null:f55d06ecfbdbfd75ec2e3274fcb2b792c1de9485:create

grant delete on samqa.incident_attachments to rl_sam_rw;

grant insert on samqa.incident_attachments to rl_sam_rw;

grant select on samqa.incident_attachments to smareedu;

grant select on samqa.incident_attachments to rl_sam_ro;

