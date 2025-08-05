-- liquibase formatted sql
-- changeset SAMQA:1754373936438 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_reports_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_reports_pkg.sql:null:c1c60920a8ea9722a4d36f9355712d1ffa467e85:create

grant execute on samqa.pc_reports_pkg to rl_sam_ro;

grant execute on samqa.pc_reports_pkg to rl_sam_rw;

grant execute on samqa.pc_reports_pkg to rl_sam1_ro;

grant debug on samqa.pc_reports_pkg to sgali;

grant debug on samqa.pc_reports_pkg to rl_sam_rw;

grant debug on samqa.pc_reports_pkg to rl_sam1_ro;

grant debug on samqa.pc_reports_pkg to rl_sam_ro;

