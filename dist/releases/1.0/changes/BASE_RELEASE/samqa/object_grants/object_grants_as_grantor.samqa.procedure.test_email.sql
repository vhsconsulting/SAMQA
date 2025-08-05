-- liquibase formatted sql
-- changeset SAMQA:1754373937231 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.test_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.test_email.sql:null:3a99ee5456fcf5f30ba8161a25a9609187fbe644:create

grant execute on samqa.test_email to rl_sam_ro;

grant execute on samqa.test_email to rl_sam_rw;

grant execute on samqa.test_email to rl_sam1_ro;

grant debug on samqa.test_email to sgali;

grant debug on samqa.test_email to rl_sam_rw;

grant debug on samqa.test_email to rl_sam1_ro;

