-- liquibase formatted sql
-- changeset SAMQA:1754373938937 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ben_plan_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ben_plan_history.sql:null:30d42266a1082e13a50d382611eba071a2096db8:create

grant delete on samqa.ben_plan_history to rl_sam_rw;

grant insert on samqa.ben_plan_history to rl_sam_rw;

grant select on samqa.ben_plan_history to rl_sam1_ro;

grant select on samqa.ben_plan_history to rl_sam_rw;

grant select on samqa.ben_plan_history to rl_sam_ro;

grant update on samqa.ben_plan_history to rl_sam_rw;

