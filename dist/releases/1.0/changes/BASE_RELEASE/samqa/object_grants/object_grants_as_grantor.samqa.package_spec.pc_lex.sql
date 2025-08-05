-- liquibase formatted sql
-- changeset SAMQA:1754373936273 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_lex.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_lex.sql:null:89d98827e1ae59c8f5ecb26b5d813bb030759a7b:create

grant execute on samqa.pc_lex to rl_sam_ro;

grant execute on samqa.pc_lex to rl_sam_rw;

grant execute on samqa.pc_lex to rl_sam1_ro;

grant debug on samqa.pc_lex to sgali;

grant debug on samqa.pc_lex to rl_sam_rw;

grant debug on samqa.pc_lex to rl_sam1_ro;

grant debug on samqa.pc_lex to rl_sam_ro;

