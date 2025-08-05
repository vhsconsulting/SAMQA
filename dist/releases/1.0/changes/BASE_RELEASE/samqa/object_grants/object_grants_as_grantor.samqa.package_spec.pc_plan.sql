-- liquibase formatted sql
-- changeset SAMQA:1754373936406 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_plan.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_plan.sql:null:4c1847c6211eb57cabea115ac81359940c312167:create

grant execute on samqa.pc_plan to rl_sam1_ro;

grant execute on samqa.pc_plan to rl_sam_rw;

grant execute on samqa.pc_plan to rl_sam_ro;

grant debug on samqa.pc_plan to rl_sam1_ro;

grant debug on samqa.pc_plan to rl_sam_ro;

grant debug on samqa.pc_plan to sgali;

grant debug on samqa.pc_plan to rl_sam_rw;

