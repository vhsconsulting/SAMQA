-- liquibase formatted sql
-- changeset SAMQA:1754373935492 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.is_number.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.is_number.sql:null:59e99c3445096a676c3f00f56623a0fc68673914:create

grant execute on samqa.is_number to rl_sam_ro;

grant execute on samqa.is_number to rl_sam_rw;

grant execute on samqa.is_number to rl_sam1_ro;

grant debug on samqa.is_number to sgali;

grant debug on samqa.is_number to rl_sam_rw;

grant debug on samqa.is_number to rl_sam1_ro;

