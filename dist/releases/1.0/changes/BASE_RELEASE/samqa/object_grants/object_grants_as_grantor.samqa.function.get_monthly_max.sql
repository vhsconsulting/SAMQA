-- liquibase formatted sql
-- changeset SAMQA:1754373935346 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_monthly_max.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_monthly_max.sql:null:8c22370a9e5a8ecd91ccb8bd21e32c1978522c3a:create

grant execute on samqa.get_monthly_max to rl_sam_ro;

grant execute on samqa.get_monthly_max to rl_sam_rw;

grant execute on samqa.get_monthly_max to rl_sam1_ro;

grant debug on samqa.get_monthly_max to sgali;

grant debug on samqa.get_monthly_max to rl_sam_rw;

grant debug on samqa.get_monthly_max to rl_sam1_ro;

