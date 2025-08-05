-- liquibase formatted sql
-- changeset SAMQA:1754373939076 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.broker_account_rnw_rev_5yr.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.broker_account_rnw_rev_5yr.sql:null:e4feff2479ae40f3697158c944bb3eee6ff31a61:create

grant select on samqa.broker_account_rnw_rev_5yr to rl_sam_ro;

grant debug on samqa.broker_account_rnw_rev_5yr to rl_sam_ro;

