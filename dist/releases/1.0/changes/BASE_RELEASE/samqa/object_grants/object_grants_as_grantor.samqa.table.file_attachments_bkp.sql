-- liquibase formatted sql
-- changeset SAMQA:1754373940486 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.file_attachments_bkp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.file_attachments_bkp.sql:null:bcc0224072c94da0aa0f4125c0f5c524349a5dee:create

grant delete on samqa.file_attachments_bkp to rl_sam_rw;

grant insert on samqa.file_attachments_bkp to rl_sam_rw;

grant select on samqa.file_attachments_bkp to rl_sam1_ro;

grant select on samqa.file_attachments_bkp to rl_sam_rw;

grant select on samqa.file_attachments_bkp to rl_sam_ro;

grant update on samqa.file_attachments_bkp to rl_sam_rw;

