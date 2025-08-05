-- liquibase formatted sql
-- changeset SAMQA:1754373936513 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_user_bank_acct.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_user_bank_acct.sql:null:9ac458ef4daa3f047e52cba020a78f785a387827:create

grant execute on samqa.pc_user_bank_acct to rl_sam_ro;

grant execute on samqa.pc_user_bank_acct to rl_sam_rw;

grant execute on samqa.pc_user_bank_acct to rl_sam1_ro;

grant debug on samqa.pc_user_bank_acct to rl_sam_ro;

grant debug on samqa.pc_user_bank_acct to sgali;

grant debug on samqa.pc_user_bank_acct to rl_sam_rw;

grant debug on samqa.pc_user_bank_acct to rl_sam1_ro;

