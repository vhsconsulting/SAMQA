-- liquibase formatted sql
-- changeset SAMQA:1754373936628 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.test_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.test_pkg.sql:null:170ee575bcdc31b5f7a76448dc1636b752e0b88b:create

grant execute on samqa.test_pkg to rl_sam1_ro;

grant execute on samqa.test_pkg to rl_sam_ro;

grant execute on samqa.test_pkg to rl_sam_rw;

grant debug on samqa.test_pkg to rl_sam1_ro;

grant debug on samqa.test_pkg to rl_sam_ro;

grant debug on samqa.test_pkg to sgali;

grant debug on samqa.test_pkg to rl_sam_rw;

