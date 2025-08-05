-- liquibase formatted sql
-- changeset SAMQA:1754373936388 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_payee.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_payee.sql:null:e77a443f82b9d0917dc05db94d6b20caf596d11b:create

grant execute on samqa.pc_payee to rl_sam_ro;

grant execute on samqa.pc_payee to rl_sam_rw;

grant execute on samqa.pc_payee to rl_sam1_ro;

grant debug on samqa.pc_payee to rl_sam_ro;

grant debug on samqa.pc_payee to sgali;

grant debug on samqa.pc_payee to rl_sam_rw;

grant debug on samqa.pc_payee to rl_sam1_ro;

