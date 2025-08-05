-- liquibase formatted sql
-- changeset SAMQA:1754373936454 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_sam_gp_intgrtn.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_sam_gp_intgrtn.sql:null:e218c25966fd9643eb3e1243c0962285c908757d:create

grant execute on samqa.pc_sam_gp_intgrtn to rl_sam_ro;

grant execute on samqa.pc_sam_gp_intgrtn to rl_sam_rw;

grant execute on samqa.pc_sam_gp_intgrtn to rl_sam1_ro;

grant debug on samqa.pc_sam_gp_intgrtn to sgali;

grant debug on samqa.pc_sam_gp_intgrtn to rl_sam_rw;

grant debug on samqa.pc_sam_gp_intgrtn to rl_sam1_ro;

grant debug on samqa.pc_sam_gp_intgrtn to rl_sam_ro;

