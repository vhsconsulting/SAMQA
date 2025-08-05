-- liquibase formatted sql
-- changeset SAMQA:1754373936310 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_nightly_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_nightly_email.sql:null:d4a3533b6d914389e4ecc4a33c8841d2b74677a0:create

grant execute on samqa.pc_nightly_email to rl_sam_ro;

grant execute on samqa.pc_nightly_email to rl_sam_rw;

grant execute on samqa.pc_nightly_email to rl_sam1_ro;

grant debug on samqa.pc_nightly_email to rl_sam_ro;

grant debug on samqa.pc_nightly_email to sgali;

grant debug on samqa.pc_nightly_email to rl_sam_rw;

grant debug on samqa.pc_nightly_email to rl_sam1_ro;

