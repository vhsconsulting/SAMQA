-- liquibase formatted sql
-- changeset SAMQA:1754373939019 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.bps_sam_balances.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.bps_sam_balances.sql:null:cb10fa5ac556ddf1e7592468a3f5674b1cd53cf6:create

grant delete on samqa.bps_sam_balances to rl_sam_rw;

grant insert on samqa.bps_sam_balances to rl_sam_rw;

grant select on samqa.bps_sam_balances to rl_sam1_ro;

grant select on samqa.bps_sam_balances to rl_sam_rw;

grant select on samqa.bps_sam_balances to rl_sam_ro;

grant update on samqa.bps_sam_balances to rl_sam_rw;

