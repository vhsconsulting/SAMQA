-- liquibase formatted sql
-- changeset SAMQA:1754373941727 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.plan_notices_stage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.plan_notices_stage.sql:null:b16ebd7e385cd4f5c2b9cc4e4a0852ee933e0f0f:create

grant delete on samqa.plan_notices_stage to rl_sam_rw;

grant insert on samqa.plan_notices_stage to rl_sam_rw;

grant select on samqa.plan_notices_stage to rl_sam1_ro;

grant select on samqa.plan_notices_stage to rl_sam_ro;

grant select on samqa.plan_notices_stage to rl_sam_rw;

grant update on samqa.plan_notices_stage to rl_sam_rw;

