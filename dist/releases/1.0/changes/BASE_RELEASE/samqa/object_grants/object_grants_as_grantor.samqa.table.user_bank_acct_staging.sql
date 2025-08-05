-- liquibase formatted sql
-- changeset SAMQA:1754373942384 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.user_bank_acct_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.user_bank_acct_staging.sql:null:bf96ee450cd803cd04313b1dac052030d06a779f:create

grant delete on samqa.user_bank_acct_staging to rl_sam_rw;

grant insert on samqa.user_bank_acct_staging to rl_sam_rw;

grant select on samqa.user_bank_acct_staging to rl_sam1_ro;

grant select on samqa.user_bank_acct_staging to rl_sam_ro;

grant select on samqa.user_bank_acct_staging to rl_sam_rw;

grant update on samqa.user_bank_acct_staging to rl_sam_rw;

