-- liquibase formatted sql
-- changeset SAMQA:1754373936347 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_online.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_online.sql:null:8dcf45782a21e83426b9b772af0e586722e615c6:create

grant execute on samqa.pc_online to rl_sam_ro;

grant execute on samqa.pc_online to rl_sam_rw;

grant execute on samqa.pc_online to rl_sam1_ro;

grant debug on samqa.pc_online to rl_sam_ro;

grant debug on samqa.pc_online to sgali;

grant debug on samqa.pc_online to rl_sam_rw;

grant debug on samqa.pc_online to rl_sam1_ro;

