-- liquibase formatted sql
-- changeset SAMQA:1754373936538 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_util.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_util.sql:null:d2b13d22c95c35d2c2137a8e290275354bf64163:create

grant execute on samqa.pc_util to rl_sam_ro;

grant execute on samqa.pc_util to rl_sam_rw;

grant execute on samqa.pc_util to rl_sam1_ro;

grant debug on samqa.pc_util to rl_sam_ro;

grant debug on samqa.pc_util to sgali;

grant debug on samqa.pc_util to rl_sam_rw;

grant debug on samqa.pc_util to rl_sam1_ro;

