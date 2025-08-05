-- liquibase formatted sql
-- changeset SAMQA:1754373937801 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.file_upload_history_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.file_upload_history_seq.sql:null:f65db1a3505335c20e8a801027eb40116c611e23:create

grant select on samqa.file_upload_history_seq to rl_sam_rw;

