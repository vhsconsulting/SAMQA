-- liquibase formatted sql
-- changeset SAMQA:1754373937239 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.tr_insert.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.tr_insert.sql:null:07e1c68f84bcaeb6909f398fae5edba798300f37:create

grant execute on samqa.tr_insert to rl_sam_ro;

grant execute on samqa.tr_insert to rl_sam_rw;

grant execute on samqa.tr_insert to rl_sam1_ro;

grant debug on samqa.tr_insert to sgali;

grant debug on samqa.tr_insert to rl_sam_rw;

grant debug on samqa.tr_insert to rl_sam1_ro;

