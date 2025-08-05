-- liquibase formatted sql
-- changeset SAMQA:1754373939774 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.deposit_reconcile_stage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.deposit_reconcile_stage.sql:null:2f3cf4c2e6171f221978f8629dbf1572411043e9:create

grant delete on samqa.deposit_reconcile_stage to rl_sam_rw;

grant insert on samqa.deposit_reconcile_stage to rl_sam_rw;

grant select on samqa.deposit_reconcile_stage to rl_sam1_ro;

grant select on samqa.deposit_reconcile_stage to rl_sam_ro;

grant select on samqa.deposit_reconcile_stage to rl_sam_rw;

grant update on samqa.deposit_reconcile_stage to rl_sam_rw;

