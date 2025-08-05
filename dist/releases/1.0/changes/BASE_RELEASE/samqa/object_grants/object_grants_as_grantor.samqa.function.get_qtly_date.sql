-- liquibase formatted sql
-- changeset SAMQA:1754373935361 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_qtly_date.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_qtly_date.sql:null:cd953ec9fd712fb26c0ac2f713f6f70197f4f814:create

grant execute on samqa.get_qtly_date to rl_sam_ro;

grant execute on samqa.get_qtly_date to rl_sam_rw;

grant execute on samqa.get_qtly_date to rl_sam1_ro;

grant debug on samqa.get_qtly_date to sgali;

grant debug on samqa.get_qtly_date to rl_sam_rw;

grant debug on samqa.get_qtly_date to rl_sam1_ro;

