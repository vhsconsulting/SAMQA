-- liquibase formatted sql
-- changeset SAMQA:1754373937996 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.metavante_errors_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.metavante_errors_seq.sql:null:02f2ee6a0e8d5692d79adb140a7ccb81ab0a7d66:create

grant select on samqa.metavante_errors_seq to rl_sam_rw;

