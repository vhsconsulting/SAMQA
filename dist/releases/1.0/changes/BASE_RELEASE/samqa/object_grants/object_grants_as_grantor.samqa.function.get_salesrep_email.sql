-- liquibase formatted sql
-- changeset SAMQA:1754373935401 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_salesrep_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_salesrep_email.sql:null:6c9238bcb554bd01647370317e81f18c17ad75ab:create

grant execute on samqa.get_salesrep_email to rl_sam1_ro;

grant execute on samqa.get_salesrep_email to rl_sam_rw;

grant execute on samqa.get_salesrep_email to rl_sam_ro;

grant debug on samqa.get_salesrep_email to rl_sam1_ro;

grant debug on samqa.get_salesrep_email to rl_sam_rw;

