-- liquibase formatted sql
-- changeset SAMQA:1754373938517 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.acn_user.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.acn_user.sql:null:6bb2656fd7596f3d9ce67e6b889aeb86c8bd9175:create

grant delete on samqa.acn_user to rl_sam_rw;

grant insert on samqa.acn_user to rl_sam_rw;

grant select on samqa.acn_user to rl_sam1_ro;

grant select on samqa.acn_user to rl_sam_ro;

grant select on samqa.acn_user to rl_sam_rw;

grant update on samqa.acn_user to rl_sam_rw;

