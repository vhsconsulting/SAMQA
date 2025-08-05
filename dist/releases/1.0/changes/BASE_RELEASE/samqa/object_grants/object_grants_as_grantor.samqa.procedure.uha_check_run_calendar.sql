-- liquibase formatted sql
-- changeset SAMQA:1754373937246 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.uha_check_run_calendar.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.uha_check_run_calendar.sql:null:c3cd83cfb8859b10736826173fb86f0f4c8c3556:create

grant execute on samqa.uha_check_run_calendar to rl_sam_ro;

grant execute on samqa.uha_check_run_calendar to rl_sam_rw;

grant execute on samqa.uha_check_run_calendar to rl_sam1_ro;

grant debug on samqa.uha_check_run_calendar to sgali;

grant debug on samqa.uha_check_run_calendar to rl_sam_rw;

grant debug on samqa.uha_check_run_calendar to rl_sam1_ro;

