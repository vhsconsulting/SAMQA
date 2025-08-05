-- liquibase formatted sql
-- changeset SAMQA:1754373936379 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_param.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_param.sql:null:5e4565b1445108edf763c9444672610d2a726ca7:create

grant execute on samqa.pc_param to rl_sam_ro;

grant execute on samqa.pc_param to rl_sam_rw;

grant execute on samqa.pc_param to cobra;

grant execute on samqa.pc_param to rl_sam1_ro;

grant debug on samqa.pc_param to rl_sam_ro;

grant debug on samqa.pc_param to sgali;

grant debug on samqa.pc_param to rl_sam_rw;

grant debug on samqa.pc_param to rl_sam1_ro;

