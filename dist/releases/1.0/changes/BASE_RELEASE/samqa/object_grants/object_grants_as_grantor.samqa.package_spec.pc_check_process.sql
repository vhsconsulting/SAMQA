-- liquibase formatted sql
-- changeset SAMQA:1754373935925 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_check_process.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_check_process.sql:null:dcc4f9c33f65c5b6e07f4b03184f4b00fb62d4db:create

grant execute on samqa.pc_check_process to rl_sam_ro;

grant execute on samqa.pc_check_process to rl_sam_rw;

grant execute on samqa.pc_check_process to rl_sam1_ro;

grant debug on samqa.pc_check_process to rl_sam_ro;

grant debug on samqa.pc_check_process to sgali;

grant debug on samqa.pc_check_process to rl_sam_rw;

grant debug on samqa.pc_check_process to rl_sam1_ro;

