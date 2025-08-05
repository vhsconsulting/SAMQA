-- liquibase formatted sql
-- changeset SAMQA:1754373937789 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.file_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.file_seq.sql:null:e340b8a36408ac93f669b3ce4c36990419076d9d:create

grant select on samqa.file_seq to rl_sam_rw;

