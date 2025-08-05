-- liquibase formatted sql
-- changeset SAMQA:1754373936224 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_group.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_group.sql:null:0a4e0478a62d389ab392501538012e416a5b9e1f:create

grant execute on samqa.pc_group to rl_sam_ro;

grant execute on samqa.pc_group to rl_sam_rw;

grant execute on samqa.pc_group to rl_sam1_ro;

grant debug on samqa.pc_group to sgali;

grant debug on samqa.pc_group to rl_sam_rw;

grant debug on samqa.pc_group to rl_sam1_ro;

grant debug on samqa.pc_group to rl_sam_ro;

