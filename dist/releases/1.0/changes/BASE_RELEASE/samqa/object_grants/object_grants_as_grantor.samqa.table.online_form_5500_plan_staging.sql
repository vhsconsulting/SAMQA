-- liquibase formatted sql
-- changeset SAMQA:1754373941417 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.online_form_5500_plan_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.online_form_5500_plan_staging.sql:null:b0e7350cd99c492e9a2145ffc82727ee55b82337:create

grant delete on samqa.online_form_5500_plan_staging to rl_sam_rw;

grant insert on samqa.online_form_5500_plan_staging to rl_sam_rw;

grant select on samqa.online_form_5500_plan_staging to rl_sam1_ro;

grant select on samqa.online_form_5500_plan_staging to rl_sam_ro;

grant select on samqa.online_form_5500_plan_staging to rl_sam_rw;

grant update on samqa.online_form_5500_plan_staging to rl_sam_rw;

