-- liquibase formatted sql
-- changeset SAMQA:1754373936026 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_crm_interface.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_crm_interface.sql:null:c7bc5370d55d408dc90d2dc0e11a605ecaf9b763:create

grant execute on samqa.pc_crm_interface to rl_sam_rw;

grant execute on samqa.pc_crm_interface to rl_sam_ro;

grant execute on samqa.pc_crm_interface to rl_sam1_ro;

grant debug on samqa.pc_crm_interface to sgali;

grant debug on samqa.pc_crm_interface to rl_sam_rw;

grant debug on samqa.pc_crm_interface to rl_sam1_ro;

grant debug on samqa.pc_crm_interface to rl_sam_ro;

