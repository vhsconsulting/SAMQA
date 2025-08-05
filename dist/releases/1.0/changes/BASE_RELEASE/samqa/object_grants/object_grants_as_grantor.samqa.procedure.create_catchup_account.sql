-- liquibase formatted sql
-- changeset SAMQA:1754373936752 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.create_catchup_account.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.create_catchup_account.sql:null:1c48dfff829e6160e832519202301e6687d4833d:create

grant execute on samqa.create_catchup_account to rl_sam_ro;

grant execute on samqa.create_catchup_account to rl_sam_rw;

grant execute on samqa.create_catchup_account to rl_sam1_ro;

grant debug on samqa.create_catchup_account to sgali;

grant debug on samqa.create_catchup_account to rl_sam_rw;

grant debug on samqa.create_catchup_account to rl_sam1_ro;

