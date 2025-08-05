-- liquibase formatted sql
-- changeset SAMQA:1754373936203 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_general_agent.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_general_agent.sql:null:04e638a3cf7af66fd7f913233d8e4dace724fa8f:create

grant execute on samqa.pc_general_agent to rl_sam_ro;

grant execute on samqa.pc_general_agent to rl_sam_rw;

grant execute on samqa.pc_general_agent to rl_sam1_ro;

grant debug on samqa.pc_general_agent to sgali;

grant debug on samqa.pc_general_agent to rl_sam_rw;

grant debug on samqa.pc_general_agent to rl_sam1_ro;

grant debug on samqa.pc_general_agent to rl_sam_ro;

