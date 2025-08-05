-- liquibase formatted sql
-- changeset SAMQA:1754373935813 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_account.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_account.sql:null:1c2f31bba46c3f38e20070b4dfb735dbdea4eb0b:create

grant execute on samqa.pc_account to rl_sam_ro;

grant execute on samqa.pc_account to rl_sam_rw;

grant execute on samqa.pc_account to rl_sam1_ro;

grant debug on samqa.pc_account to rl_sam_ro;

grant debug on samqa.pc_account to sgali;

grant debug on samqa.pc_account to rl_sam_rw;

grant debug on samqa.pc_account to rl_sam1_ro;

