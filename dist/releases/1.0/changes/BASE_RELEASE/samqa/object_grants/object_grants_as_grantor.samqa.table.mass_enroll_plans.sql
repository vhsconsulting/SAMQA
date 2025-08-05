-- liquibase formatted sql
-- changeset SAMQA:1754373941055 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.mass_enroll_plans.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.mass_enroll_plans.sql:null:e7b63da0c2f02cc7bffb2fea64f560e9f36a279a:create

grant delete on samqa.mass_enroll_plans to rl_sam_rw;

grant insert on samqa.mass_enroll_plans to rl_sam_rw;

grant select on samqa.mass_enroll_plans to rl_sam1_ro;

grant select on samqa.mass_enroll_plans to rl_sam_rw;

grant select on samqa.mass_enroll_plans to rl_sam_ro;

grant update on samqa.mass_enroll_plans to rl_sam_rw;

