-- liquibase formatted sql
-- changeset SAMQA:1754373937436 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.change_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.change_id_seq.sql:null:98dbef19af5fd315e6750ddbae35251a00f5159c:create

grant alter on samqa.change_id_seq to public;

grant select on samqa.change_id_seq to public;

grant select on samqa.change_id_seq to rl_sam_rw;

