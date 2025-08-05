-- liquibase formatted sql
-- changeset SAMQA:1754373936833 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.delete_scheduler.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.delete_scheduler.sql:null:68de2e7386ad741f81bec2fa1c65817a1da2007b:create

grant execute on samqa.delete_scheduler to rl_sam_ro;

grant execute on samqa.delete_scheduler to rl_sam_rw;

grant execute on samqa.delete_scheduler to rl_sam1_ro;

grant debug on samqa.delete_scheduler to rl_sam_rw;

grant debug on samqa.delete_scheduler to rl_sam1_ro;

