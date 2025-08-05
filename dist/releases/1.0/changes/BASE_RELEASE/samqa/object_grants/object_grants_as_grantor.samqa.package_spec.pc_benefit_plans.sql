-- liquibase formatted sql
-- changeset SAMQA:1754373935908 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_benefit_plans.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_benefit_plans.sql:null:e43c52212577c98e16f16887f38a86baa22e94d0:create

grant execute on samqa.pc_benefit_plans to rl_sam_ro;

grant execute on samqa.pc_benefit_plans to rl_temp_access_ro;

grant execute on samqa.pc_benefit_plans to rl_sam_rw;

grant execute on samqa.pc_benefit_plans to rl_sam1_ro;

grant debug on samqa.pc_benefit_plans to rl_sam_ro;

grant debug on samqa.pc_benefit_plans to rl_temp_access_ro;

grant debug on samqa.pc_benefit_plans to sgali;

grant debug on samqa.pc_benefit_plans to rl_sam_rw;

grant debug on samqa.pc_benefit_plans to rl_sam1_ro;

