-- liquibase formatted sql
-- changeset SAMQA:1754373941403 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.online_enroll_plans.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.online_enroll_plans.sql:null:9e77c0cc3725f281dcedeff18fc1e83f27960c71:create

grant delete on samqa.online_enroll_plans to rl_sam_rw;

grant insert on samqa.online_enroll_plans to rl_sam_rw;

grant select on samqa.online_enroll_plans to rl_sam1_ro;

grant select on samqa.online_enroll_plans to rl_sam_rw;

grant select on samqa.online_enroll_plans to rl_sam_ro;

grant update on samqa.online_enroll_plans to rl_sam_rw;

