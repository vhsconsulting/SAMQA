-- liquibase formatted sql
-- changeset SAMQA:1754373941437 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.online_fsa_hra_plan_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.online_fsa_hra_plan_staging.sql:null:c8b651d5cd8692f69c37721004b1c45b989be6d4:create

grant delete on samqa.online_fsa_hra_plan_staging to rl_sam_rw;

grant insert on samqa.online_fsa_hra_plan_staging to rl_sam_rw;

grant select on samqa.online_fsa_hra_plan_staging to rl_sam_rw;

grant select on samqa.online_fsa_hra_plan_staging to rl_sam_ro;

grant select on samqa.online_fsa_hra_plan_staging to rl_sam1_ro;

grant update on samqa.online_fsa_hra_plan_staging to rl_sam_rw;

