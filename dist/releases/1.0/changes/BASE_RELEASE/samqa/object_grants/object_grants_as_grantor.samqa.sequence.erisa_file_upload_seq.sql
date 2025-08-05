-- liquibase formatted sql
-- changeset SAMQA:1754373937753 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.erisa_file_upload_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.erisa_file_upload_seq.sql:null:4cec8b33e18d6276c81f7b6403f276514f57946b:create

grant select on samqa.erisa_file_upload_seq to rl_sam_rw;

