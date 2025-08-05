-- liquibase formatted sql
-- changeset SAMQA:1754373941751 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.portfolio_accounts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.portfolio_accounts.sql:null:53036b662f35958902adc2938695b23aa9fc560c:create

grant delete on samqa.portfolio_accounts to rl_sam_rw;

grant insert on samqa.portfolio_accounts to rl_sam_rw;

grant select on samqa.portfolio_accounts to rl_sam1_ro;

grant select on samqa.portfolio_accounts to rl_sam_rw;

grant select on samqa.portfolio_accounts to rl_sam_ro;

grant update on samqa.portfolio_accounts to rl_sam_rw;

