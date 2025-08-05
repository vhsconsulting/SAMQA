-- liquibase formatted sql
-- changeset SAMQA:1754373938895 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ben_plan_coverages.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ben_plan_coverages.sql:null:34c538670b9a4e0ddd8405a1cde962ae521e6f04:create

grant delete on samqa.ben_plan_coverages to rl_sam_rw;

grant insert on samqa.ben_plan_coverages to rl_sam_rw;

grant select on samqa.ben_plan_coverages to rl_sam1_ro;

grant select on samqa.ben_plan_coverages to rl_sam_rw;

grant select on samqa.ben_plan_coverages to rl_sam_ro;

grant update on samqa.ben_plan_coverages to rl_sam_rw;

