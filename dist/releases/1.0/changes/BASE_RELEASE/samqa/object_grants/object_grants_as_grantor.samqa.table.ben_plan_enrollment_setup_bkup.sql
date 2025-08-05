-- liquibase formatted sql
-- changeset SAMQA:1754373938928 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ben_plan_enrollment_setup_bkup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ben_plan_enrollment_setup_bkup.sql:null:1471c831e276d9cc6b505e46dc02a48880e8d86b:create

grant delete on samqa.ben_plan_enrollment_setup_bkup to rl_sam_rw;

grant insert on samqa.ben_plan_enrollment_setup_bkup to rl_sam_rw;

grant select on samqa.ben_plan_enrollment_setup_bkup to rl_sam1_ro;

grant select on samqa.ben_plan_enrollment_setup_bkup to rl_sam_ro;

grant select on samqa.ben_plan_enrollment_setup_bkup to rl_sam_rw;

grant update on samqa.ben_plan_enrollment_setup_bkup to rl_sam_rw;

