-- liquibase formatted sql
-- changeset SAMQA:1754373943163 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.brokreg_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.brokreg_v.sql:null:41e2403c3c8a21c11be0de90a34910dd582c70cf:create

grant select on samqa.brokreg_v to rl_sam1_ro;

grant select on samqa.brokreg_v to rl_sam_rw;

grant select on samqa.brokreg_v to rl_sam_ro;

grant select on samqa.brokreg_v to sgali;

