-- liquibase formatted sql
-- changeset SAMQA:1754373935857 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_acn_migration.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_acn_migration.sql:null:ceadd6711353febbc3a0ae88a23979a389f38473:create

grant execute on samqa.pc_acn_migration to rl_sam_rw;

grant execute on samqa.pc_acn_migration to rl_sam1_ro;

grant execute on samqa.pc_acn_migration to rl_sam_ro;

grant debug on samqa.pc_acn_migration to rl_sam_rw;

grant debug on samqa.pc_acn_migration to rl_sam1_ro;

grant debug on samqa.pc_acn_migration to rl_sam_ro;

