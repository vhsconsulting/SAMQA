-- liquibase formatted sql
-- changeset SAMQA:1754373936356 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_online_enroll_dml.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_online_enroll_dml.sql:null:5622c098a171e92f9aaff30a4dd4363d4614d886:create

grant execute on samqa.pc_online_enroll_dml to rl_sam_ro;

grant execute on samqa.pc_online_enroll_dml to rl_sam_rw;

grant execute on samqa.pc_online_enroll_dml to rl_sam1_ro;

grant debug on samqa.pc_online_enroll_dml to rl_sam_ro;

grant debug on samqa.pc_online_enroll_dml to sgali;

grant debug on samqa.pc_online_enroll_dml to rl_sam_rw;

grant debug on samqa.pc_online_enroll_dml to rl_sam1_ro;

