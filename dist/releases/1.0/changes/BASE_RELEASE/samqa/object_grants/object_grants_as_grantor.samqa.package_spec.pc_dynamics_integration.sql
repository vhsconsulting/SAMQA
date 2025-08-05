-- liquibase formatted sql
-- changeset SAMQA:1754373936066 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_dynamics_integration.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_dynamics_integration.sql:null:a0f059612cff6bf52548e5ea85b3c4a4c72b2e53:create

grant execute on samqa.pc_dynamics_integration to rl_sam_ro;

grant debug on samqa.pc_dynamics_integration to rl_sam_ro;

