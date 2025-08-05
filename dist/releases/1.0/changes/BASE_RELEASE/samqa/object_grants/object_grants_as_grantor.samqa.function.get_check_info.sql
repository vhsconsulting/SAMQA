-- liquibase formatted sql
-- changeset SAMQA:1754373935254 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_check_info.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_check_info.sql:null:d35ee61508b677e53dc3416d30475750e653bc66:create

grant execute on samqa.get_check_info to rl_sam_ro;

grant execute on samqa.get_check_info to rl_sam_rw;

grant execute on samqa.get_check_info to rl_sam1_ro;

grant debug on samqa.get_check_info to sgali;

grant debug on samqa.get_check_info to rl_sam_rw;

grant debug on samqa.get_check_info to rl_sam1_ro;

