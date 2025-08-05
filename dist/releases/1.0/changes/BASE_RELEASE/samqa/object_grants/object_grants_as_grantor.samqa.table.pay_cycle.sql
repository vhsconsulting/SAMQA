-- liquibase formatted sql
-- changeset SAMQA:1754373941551 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.pay_cycle.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.pay_cycle.sql:null:8c12c33a6a26ac4eff81efde6407b5bda3ea8b23:create

grant delete on samqa.pay_cycle to rl_sam_rw;

grant insert on samqa.pay_cycle to rl_sam_rw;

grant select on samqa.pay_cycle to rl_sam_ro;

grant select on samqa.pay_cycle to rl_sam1_ro;

grant select on samqa.pay_cycle to rl_sam_rw;

grant update on samqa.pay_cycle to rl_sam_rw;

