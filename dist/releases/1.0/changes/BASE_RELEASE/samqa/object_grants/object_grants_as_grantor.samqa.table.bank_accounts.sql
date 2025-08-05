-- liquibase formatted sql
-- changeset SAMQA:1754373938818 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.bank_accounts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.bank_accounts.sql:null:02f573fa5af4aec1878e9b29ae395cdc798affc6:create

grant alter on samqa.bank_accounts to shavee;

grant delete on samqa.bank_accounts to rl_sam_rw;

grant delete on samqa.bank_accounts to shavee;

grant index on samqa.bank_accounts to shavee;

grant insert on samqa.bank_accounts to rl_sam_rw;

grant insert on samqa.bank_accounts to shavee;

grant select on samqa.bank_accounts to shavee;

grant select on samqa.bank_accounts to rl_sam_ro;

grant select on samqa.bank_accounts to rl_sam_rw;

grant select on samqa.bank_accounts to rl_sam1_ro;

grant update on samqa.bank_accounts to shavee;

grant update on samqa.bank_accounts to rl_sam_rw;

grant references on samqa.bank_accounts to shavee;

grant read on samqa.bank_accounts to shavee;

grant on commit refresh on samqa.bank_accounts to shavee;

grant query rewrite on samqa.bank_accounts to shavee;

grant debug on samqa.bank_accounts to shavee;

grant flashback on samqa.bank_accounts to shavee;

