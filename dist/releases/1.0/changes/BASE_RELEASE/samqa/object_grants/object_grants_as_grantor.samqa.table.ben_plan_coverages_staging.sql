-- liquibase formatted sql
-- changeset SAMQA:1754373938903 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ben_plan_coverages_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ben_plan_coverages_staging.sql:null:7d993321cce2f67a5ff4040b4fd1f11af4b5a702:create

grant delete on samqa.ben_plan_coverages_staging to rl_sam_rw;

grant insert on samqa.ben_plan_coverages_staging to rl_sam_rw;

grant select on samqa.ben_plan_coverages_staging to rl_sam1_ro;

grant select on samqa.ben_plan_coverages_staging to rl_sam_rw;

grant select on samqa.ben_plan_coverages_staging to rl_sam_ro;

grant update on samqa.ben_plan_coverages_staging to rl_sam_rw;

