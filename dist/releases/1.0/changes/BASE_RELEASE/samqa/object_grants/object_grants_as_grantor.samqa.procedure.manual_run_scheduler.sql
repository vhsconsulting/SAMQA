-- liquibase formatted sql
-- changeset SAMQA:1754373936922 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.manual_run_scheduler.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.manual_run_scheduler.sql:null:dd3fea907acdd306d544995c18fe63db31ed76de:create

grant execute on samqa.manual_run_scheduler to rl_sam_ro;

grant execute on samqa.manual_run_scheduler to rl_sam_rw;

grant execute on samqa.manual_run_scheduler to rl_sam1_ro;

grant debug on samqa.manual_run_scheduler to rl_sam_rw;

grant debug on samqa.manual_run_scheduler to rl_sam1_ro;

