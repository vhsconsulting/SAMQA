-- liquibase formatted sql
-- changeset SAMQA:1754373942346 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.toad_plan_table.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.toad_plan_table.sql:null:476797ecf161235418b0cc4469271756d6ea9a5e:create

grant delete on samqa.toad_plan_table to rl_sam_rw;

grant delete on samqa.toad_plan_table to public;

grant insert on samqa.toad_plan_table to rl_sam_rw;

grant insert on samqa.toad_plan_table to public;

grant select on samqa.toad_plan_table to rl_sam1_ro;

grant select on samqa.toad_plan_table to rl_sam_rw;

grant select on samqa.toad_plan_table to rl_sam_ro;

grant select on samqa.toad_plan_table to public;

grant update on samqa.toad_plan_table to rl_sam_rw;

grant update on samqa.toad_plan_table to public;

