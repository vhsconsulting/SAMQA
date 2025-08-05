-- liquibase formatted sql
-- changeset SAMQA:1754373935797 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.ora81pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.ora81pkg.sql:null:2704a64b393afe42e2a0ac7a2b7ab836ace12690:create

grant execute on samqa.ora81pkg to rl_sam_ro;

grant execute on samqa.ora81pkg to rl_sam_rw;

grant execute on samqa.ora81pkg to rl_sam1_ro;

grant debug on samqa.ora81pkg to rl_sam_ro;

grant debug on samqa.ora81pkg to sgali;

grant debug on samqa.ora81pkg to rl_sam_rw;

grant debug on samqa.ora81pkg to rl_sam1_ro;

