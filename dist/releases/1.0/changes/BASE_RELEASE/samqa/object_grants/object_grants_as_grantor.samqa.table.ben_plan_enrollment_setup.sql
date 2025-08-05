-- liquibase formatted sql
-- changeset SAMQA:1754373938920 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ben_plan_enrollment_setup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ben_plan_enrollment_setup.sql:null:7e2af8d0af17222716a5eb26cc5481287cb10ebc:create

grant delete on samqa.ben_plan_enrollment_setup to rl_sam_rw;

grant insert on samqa.ben_plan_enrollment_setup to rl_sam_rw;

grant select on samqa.ben_plan_enrollment_setup to rl_sam1_ro;

grant select on samqa.ben_plan_enrollment_setup to rl_sam_rw;

grant select on samqa.ben_plan_enrollment_setup to rl_sam_ro;

grant update on samqa.ben_plan_enrollment_setup to rl_sam_rw;

