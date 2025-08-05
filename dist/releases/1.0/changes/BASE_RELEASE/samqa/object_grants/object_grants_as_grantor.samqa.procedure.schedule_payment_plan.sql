-- liquibase formatted sql
-- changeset SAMQA:1754373937180 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.schedule_payment_plan.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.schedule_payment_plan.sql:null:72f191fc93e782df86f9bdb90d11721994041ed6:create

grant execute on samqa.schedule_payment_plan to rl_sam_ro;

grant execute on samqa.schedule_payment_plan to rl_sam_rw;

grant execute on samqa.schedule_payment_plan to rl_sam1_ro;

grant debug on samqa.schedule_payment_plan to sgali;

grant debug on samqa.schedule_payment_plan to rl_sam_rw;

grant debug on samqa.schedule_payment_plan to rl_sam1_ro;

