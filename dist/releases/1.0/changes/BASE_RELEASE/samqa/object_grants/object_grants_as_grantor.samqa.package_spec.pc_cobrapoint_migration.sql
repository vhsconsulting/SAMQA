-- liquibase formatted sql
-- changeset SAMQA:1754373935993 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_cobrapoint_migration.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_cobrapoint_migration.sql:null:cc3ed81311ab24ba6094003c28ceea1238afe4d0:create

grant execute on samqa.pc_cobrapoint_migration to rl_sam_ro;

grant execute on samqa.pc_cobrapoint_migration to rl_sam_rw;

grant execute on samqa.pc_cobrapoint_migration to rl_sam1_ro;

grant debug on samqa.pc_cobrapoint_migration to rl_sam_ro;

grant debug on samqa.pc_cobrapoint_migration to sgali;

grant debug on samqa.pc_cobrapoint_migration to rl_sam_rw;

grant debug on samqa.pc_cobrapoint_migration to rl_sam1_ro;

