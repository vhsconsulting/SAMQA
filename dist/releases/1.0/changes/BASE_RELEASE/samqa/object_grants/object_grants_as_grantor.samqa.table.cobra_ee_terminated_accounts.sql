-- liquibase formatted sql
-- changeset SAMQA:1754373939471 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.cobra_ee_terminated_accounts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.cobra_ee_terminated_accounts.sql:null:0a36b9450237880a1d62e26b1556fb4ee800a88f:create

grant delete on samqa.cobra_ee_terminated_accounts to rl_sam_rw;

grant insert on samqa.cobra_ee_terminated_accounts to rl_sam_rw;

grant select on samqa.cobra_ee_terminated_accounts to rl_sam1_ro;

grant select on samqa.cobra_ee_terminated_accounts to rl_sam_ro;

grant select on samqa.cobra_ee_terminated_accounts to rl_sam_rw;

grant update on samqa.cobra_ee_terminated_accounts to rl_sam_rw;

