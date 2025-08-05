-- liquibase formatted sql
-- changeset SAMQA:1754373936470 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_sbs_migration.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_sbs_migration.sql:null:1d397115e0aeae3fd594ca1f4a7144037d516671:create

grant execute on samqa.pc_sbs_migration to rl_sam_rw;

grant execute on samqa.pc_sbs_migration to rl_sam1_ro;

grant execute on samqa.pc_sbs_migration to rl_sam_ro;

grant debug on samqa.pc_sbs_migration to rl_sam_rw;

grant debug on samqa.pc_sbs_migration to rl_sam1_ro;

grant debug on samqa.pc_sbs_migration to rl_sam_ro;

