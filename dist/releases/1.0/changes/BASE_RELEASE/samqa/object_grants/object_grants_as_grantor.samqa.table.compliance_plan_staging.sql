-- liquibase formatted sql
-- changeset SAMQA:1754373939516 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.compliance_plan_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.compliance_plan_staging.sql:null:ceedddf06e19e1483109f6dcd5a281f8b2bd81af:create

grant delete on samqa.compliance_plan_staging to rl_sam_rw;

grant insert on samqa.compliance_plan_staging to rl_sam_rw;

grant select on samqa.compliance_plan_staging to rl_sam1_ro;

grant select on samqa.compliance_plan_staging to rl_sam_ro;

grant select on samqa.compliance_plan_staging to rl_sam_rw;

grant update on samqa.compliance_plan_staging to rl_sam_rw;

