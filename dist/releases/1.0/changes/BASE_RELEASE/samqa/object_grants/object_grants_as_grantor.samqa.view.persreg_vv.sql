-- liquibase formatted sql
-- changeset SAMQA:1754373944922 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.persreg_vv.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.persreg_vv.sql:null:da57cfcd0c1705d23b1c534a452a690ef703aaf4:create

grant select on samqa.persreg_vv to rl_sam1_ro;

grant select on samqa.persreg_vv to rl_sam_rw;

grant select on samqa.persreg_vv to rl_sam_ro;

grant select on samqa.persreg_vv to sgali;

