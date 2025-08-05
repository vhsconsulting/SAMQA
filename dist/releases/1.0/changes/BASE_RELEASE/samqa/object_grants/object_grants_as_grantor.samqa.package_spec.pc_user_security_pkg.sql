-- liquibase formatted sql
-- changeset SAMQA:1754373936521 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_user_security_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_user_security_pkg.sql:null:3fd35fd21475663e176d0430f79ae84ab950a172:create

grant execute on samqa.pc_user_security_pkg to rl_sam_ro;

grant execute on samqa.pc_user_security_pkg to rl_sam_rw;

grant execute on samqa.pc_user_security_pkg to rl_sam1_ro;

grant debug on samqa.pc_user_security_pkg to rl_sam_ro;

grant debug on samqa.pc_user_security_pkg to sgali;

grant debug on samqa.pc_user_security_pkg to rl_sam_rw;

grant debug on samqa.pc_user_security_pkg to rl_sam1_ro;

