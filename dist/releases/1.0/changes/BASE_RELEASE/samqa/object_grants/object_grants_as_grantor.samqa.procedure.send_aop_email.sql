-- liquibase formatted sql
-- changeset SAMQA:1754373937187 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.send_aop_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.send_aop_email.sql:null:fc0a16f29ae9df765f8ab8efe031126e963201d9:create

grant execute on samqa.send_aop_email to rl_sam_ro;

grant execute on samqa.send_aop_email to rl_sam1_ro;

grant execute on samqa.send_aop_email to rl_sam_rw;

grant debug on samqa.send_aop_email to rl_sam1_ro;

grant debug on samqa.send_aop_email to rl_sam_rw;

