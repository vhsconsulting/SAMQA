-- liquibase formatted sql
-- changeset SAMQA:1754373936745 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.copy_rate_plan.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.copy_rate_plan.sql:null:72cdf91eeff89aaba69f46d2b82578135e468ce4:create

grant execute on samqa.copy_rate_plan to rl_sam_ro;

