-- liquibase formatted sql
-- changeset SAMQA:1754373937204 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.send_email_balance_register.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.send_email_balance_register.sql:null:9003ce61d2c1dd17a1709e7420a881e979652f42:create

grant execute on samqa.send_email_balance_register to rl_sam_ro;

grant execute on samqa.send_email_balance_register to rl_sam_rw;

grant execute on samqa.send_email_balance_register to rl_sam1_ro;

grant debug on samqa.send_email_balance_register to sgali;

grant debug on samqa.send_email_balance_register to rl_sam_rw;

grant debug on samqa.send_email_balance_register to rl_sam1_ro;

