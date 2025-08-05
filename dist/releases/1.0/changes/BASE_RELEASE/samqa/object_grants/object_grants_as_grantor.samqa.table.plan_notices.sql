-- liquibase formatted sql
-- changeset SAMQA:1754373941718 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.plan_notices.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.plan_notices.sql:null:1f523bcfafb1775a0c6e80284ed23639efb9a7a9:create

grant delete on samqa.plan_notices to rl_sam_rw;

grant insert on samqa.plan_notices to rl_sam_rw;

grant select on samqa.plan_notices to rl_sam1_ro;

grant select on samqa.plan_notices to rl_sam_rw;

grant select on samqa.plan_notices to rl_sam_ro;

grant update on samqa.plan_notices to rl_sam_rw;

