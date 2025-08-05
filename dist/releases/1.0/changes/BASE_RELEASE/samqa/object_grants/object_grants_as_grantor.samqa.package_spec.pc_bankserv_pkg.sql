-- liquibase formatted sql
-- changeset SAMQA:1754373935890 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_bankserv_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_bankserv_pkg.sql:null:1b6dbf67f9e2e77ac6c9a3177ee924b91b8c8091:create

grant execute on samqa.pc_bankserv_pkg to rl_sam_rw;

grant execute on samqa.pc_bankserv_pkg to rl_sam_ro;

grant execute on samqa.pc_bankserv_pkg to rl_sam1_ro;

grant debug on samqa.pc_bankserv_pkg to sgali;

grant debug on samqa.pc_bankserv_pkg to rl_sam_rw;

grant debug on samqa.pc_bankserv_pkg to rl_sam1_ro;

grant debug on samqa.pc_bankserv_pkg to rl_sam_ro;

