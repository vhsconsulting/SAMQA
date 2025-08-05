-- liquibase formatted sql
-- changeset SAMQA:1754373937720 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.eob_detail_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.eob_detail_seq.sql:null:f58928f6a5e8c79e130b70a7fe42acc8c249a97c:create

grant select on samqa.eob_detail_seq to rl_sam_rw;

