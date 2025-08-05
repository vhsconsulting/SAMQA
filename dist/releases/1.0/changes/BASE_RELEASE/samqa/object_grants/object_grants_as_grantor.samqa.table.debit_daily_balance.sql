-- liquibase formatted sql
-- changeset SAMQA:1754373939663 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.debit_daily_balance.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.debit_daily_balance.sql:null:610e89c56ff62352c5c3b4dad8b4dd6f33927492:create

grant delete on samqa.debit_daily_balance to rl_sam_rw;

grant insert on samqa.debit_daily_balance to rl_sam_rw;

grant select on samqa.debit_daily_balance to rl_sam1_ro;

grant select on samqa.debit_daily_balance to rl_sam_rw;

grant select on samqa.debit_daily_balance to rl_sam_ro;

grant update on samqa.debit_daily_balance to rl_sam_rw;

