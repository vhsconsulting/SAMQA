-- liquibase formatted sql
-- changeset SAMQA:1754373942353 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.transaction_bank_accounts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.transaction_bank_accounts.sql:null:c3ad8e887011d851551fba3a74d7ebe95d2d32a2:create

grant delete on samqa.transaction_bank_accounts to rl_sam_rw;

grant insert on samqa.transaction_bank_accounts to rl_sam_rw;

grant select on samqa.transaction_bank_accounts to rl_sam1_ro;

grant select on samqa.transaction_bank_accounts to rl_sam_rw;

grant select on samqa.transaction_bank_accounts to rl_sam_ro;

grant update on samqa.transaction_bank_accounts to rl_sam_rw;

