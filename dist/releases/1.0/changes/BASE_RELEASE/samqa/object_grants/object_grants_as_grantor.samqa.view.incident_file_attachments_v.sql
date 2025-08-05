-- liquibase formatted sql
-- changeset SAMQA:1754373944377 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.incident_file_attachments_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.incident_file_attachments_v.sql:null:b8596de245c1c80e785d62f550896113dfaf8a53:create

grant select on samqa.incident_file_attachments_v to rl_sam_ro;

grant select on samqa.incident_file_attachments_v to smareedu;

