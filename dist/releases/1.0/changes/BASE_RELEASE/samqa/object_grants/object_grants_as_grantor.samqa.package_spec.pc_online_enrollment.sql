-- liquibase formatted sql
-- changeset SAMQA:1754373936365 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_online_enrollment.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_online_enrollment.sql:null:084a050dac2fb4885220f5f7f69becf7e77912a9:create

grant execute on samqa.pc_online_enrollment to rl_sam_ro;

grant execute on samqa.pc_online_enrollment to rl_sam_rw;

grant execute on samqa.pc_online_enrollment to rl_sam1_ro;

grant debug on samqa.pc_online_enrollment to rl_sam_ro;

grant debug on samqa.pc_online_enrollment to sgali;

grant debug on samqa.pc_online_enrollment to rl_sam_rw;

grant debug on samqa.pc_online_enrollment to rl_sam1_ro;

