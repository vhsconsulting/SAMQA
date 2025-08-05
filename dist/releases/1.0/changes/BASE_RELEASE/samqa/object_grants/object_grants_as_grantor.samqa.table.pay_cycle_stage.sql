-- liquibase formatted sql
-- changeset SAMQA:1754373941559 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.pay_cycle_stage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.pay_cycle_stage.sql:null:becb823e8639a732509b61382543838d34bcefe2:create

grant delete on samqa.pay_cycle_stage to rl_sam_rw;

grant insert on samqa.pay_cycle_stage to rl_sam_rw;

grant select on samqa.pay_cycle_stage to rl_sam1_ro;

grant select on samqa.pay_cycle_stage to rl_sam_rw;

grant select on samqa.pay_cycle_stage to rl_sam_ro;

grant update on samqa.pay_cycle_stage to rl_sam_rw;

