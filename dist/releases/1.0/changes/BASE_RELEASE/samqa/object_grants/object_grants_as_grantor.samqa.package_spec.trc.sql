-- liquibase formatted sql
-- changeset SAMQA:1754373936636 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.trc.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.trc.sql:null:18014cb3c40795fd743d6b162c39c83e6984c6b6:create

grant execute on samqa.trc to rl_sam_ro;

grant execute on samqa.trc to rl_sam_rw;

grant execute on samqa.trc to rl_sam1_ro;

grant debug on samqa.trc to sgali;

grant debug on samqa.trc to rl_sam_rw;

grant debug on samqa.trc to rl_sam1_ro;

grant debug on samqa.trc to rl_sam_ro;

