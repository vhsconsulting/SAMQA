-- liquibase formatted sql
-- changeset SAMQA:1754373936043 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_debit.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_debit.sql:null:9b7d23a1842daa6f766ea26ac89635689f525993:create

grant execute on samqa.pc_debit to rl_sam_ro;

grant execute on samqa.pc_debit to rl_sam_rw;

grant execute on samqa.pc_debit to rl_sam1_ro;

grant debug on samqa.pc_debit to rl_sam_ro;

grant debug on samqa.pc_debit to sgali;

grant debug on samqa.pc_debit to rl_sam_rw;

grant debug on samqa.pc_debit to rl_sam1_ro;

