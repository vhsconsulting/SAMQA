-- liquibase formatted sql
-- changeset SAMQA:1754373940694 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.health_plan_upload.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.health_plan_upload.sql:null:3d1c81b3b3c12d07d7ee96d5239d12886939d44c:create

grant delete on samqa.health_plan_upload to rl_sam_rw;

grant insert on samqa.health_plan_upload to rl_sam_rw;

grant select on samqa.health_plan_upload to rl_sam1_ro;

grant select on samqa.health_plan_upload to rl_sam_rw;

grant select on samqa.health_plan_upload to rl_sam_ro;

grant update on samqa.health_plan_upload to rl_sam_rw;

