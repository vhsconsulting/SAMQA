-- liquibase formatted sql
-- changeset SAMQA:1754373938911 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ben_plan_denials.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ben_plan_denials.sql:null:bf3649435ec175b8359ce64f58d318be089e32be:create

grant delete on samqa.ben_plan_denials to rl_sam_rw;

grant insert on samqa.ben_plan_denials to rl_sam_rw;

grant select on samqa.ben_plan_denials to rl_sam1_ro;

grant select on samqa.ben_plan_denials to rl_sam_rw;

grant select on samqa.ben_plan_denials to rl_sam_ro;

grant update on samqa.ben_plan_denials to rl_sam_rw;

