-- liquibase formatted sql
-- changeset SAMQA:1754373935553 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.sam_apex_error_handling.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.sam_apex_error_handling.sql:null:dd8c1357c03f3e618c2fb968758f2d2bd2c210a3:create

grant execute on samqa.sam_apex_error_handling to rl_sam_ro;

grant execute on samqa.sam_apex_error_handling to rl_sam_rw;

grant execute on samqa.sam_apex_error_handling to rl_sam1_ro;

grant debug on samqa.sam_apex_error_handling to sgali;

grant debug on samqa.sam_apex_error_handling to rl_sam_rw;

grant debug on samqa.sam_apex_error_handling to rl_sam1_ro;

