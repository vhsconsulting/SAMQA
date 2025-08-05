-- liquibase formatted sql
-- changeset SAMQA:1754373936529 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_users.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_users.sql:null:5edce18594ee261778d2beefa06072ef4f2f9ca3:create

grant execute on samqa.pc_users to rl_sam_ro;

grant execute on samqa.pc_users to rl_sam_rw;

grant execute on samqa.pc_users to rl_sam1_ro;

grant debug on samqa.pc_users to rl_sam_ro;

grant debug on samqa.pc_users to sgali;

grant debug on samqa.pc_users to rl_sam_rw;

grant debug on samqa.pc_users to rl_sam1_ro;

