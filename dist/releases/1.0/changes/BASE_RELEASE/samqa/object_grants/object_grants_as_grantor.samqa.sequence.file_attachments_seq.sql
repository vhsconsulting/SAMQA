-- liquibase formatted sql
-- changeset SAMQA:1754373937789 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.file_attachments_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.file_attachments_seq.sql:null:f65410681bf39ce8d2e634fe7a388b6ee4c940d2:create

grant select on samqa.file_attachments_seq to rl_sam_rw;

