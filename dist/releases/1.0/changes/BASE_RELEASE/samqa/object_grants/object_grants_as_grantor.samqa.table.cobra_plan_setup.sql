-- liquibase formatted sql
-- changeset SAMQA:1754373939500 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.cobra_plan_setup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.cobra_plan_setup.sql:null:3f83a4a25ba5f1e9b9134fc7b45b329e31dce349:create

grant delete on samqa.cobra_plan_setup to rl_sam_rw;

grant insert on samqa.cobra_plan_setup to rl_sam_rw;

grant select on samqa.cobra_plan_setup to rl_sam1_ro;

grant select on samqa.cobra_plan_setup to rl_sam_rw;

grant select on samqa.cobra_plan_setup to rl_sam_ro;

grant update on samqa.cobra_plan_setup to rl_sam_rw;

