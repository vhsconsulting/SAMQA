-- liquibase formatted sql
-- changeset SAMQA:1754373937021 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.process_manual_ach_schedule.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.process_manual_ach_schedule.sql:null:9c8f82bcdfc3476c7c775aea15ca4fa085d0fdc9:create

grant execute on samqa.process_manual_ach_schedule to rl_sam_ro;

grant execute on samqa.process_manual_ach_schedule to rl_sam_rw;

grant execute on samqa.process_manual_ach_schedule to rl_sam1_ro;

grant debug on samqa.process_manual_ach_schedule to rl_sam_rw;

grant debug on samqa.process_manual_ach_schedule to rl_sam1_ro;

