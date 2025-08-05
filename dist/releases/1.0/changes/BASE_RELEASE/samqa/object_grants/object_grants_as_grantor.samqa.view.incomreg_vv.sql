-- liquibase formatted sql
-- changeset SAMQA:1754373944443 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.incomreg_vv.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.incomreg_vv.sql:null:1c3d3c39858d4e9ae618deb9bd3eb2edca60aa23:create

grant select on samqa.incomreg_vv to rl_sam1_ro;

grant select on samqa.incomreg_vv to rl_sam_rw;

grant select on samqa.incomreg_vv to rl_sam_ro;

grant select on samqa.incomreg_vv to sgali;

