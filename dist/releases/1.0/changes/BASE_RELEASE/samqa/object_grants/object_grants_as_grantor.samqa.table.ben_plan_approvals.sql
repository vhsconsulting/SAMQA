-- liquibase formatted sql
-- changeset SAMQA:1754373938887 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ben_plan_approvals.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ben_plan_approvals.sql:null:553f4ee22618b58a046ea4d26d1e8e614830aff1:create

grant delete on samqa.ben_plan_approvals to rl_sam_rw;

grant insert on samqa.ben_plan_approvals to rl_sam_rw;

grant select on samqa.ben_plan_approvals to rl_sam1_ro;

grant select on samqa.ben_plan_approvals to rl_sam_rw;

grant select on samqa.ben_plan_approvals to rl_sam_ro;

grant update on samqa.ben_plan_approvals to rl_sam_rw;

