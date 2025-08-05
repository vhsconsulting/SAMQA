-- liquibase formatted sql
-- changeset SAMQA:1754373944659 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.mypaymen.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.mypaymen.sql:null:7226e3733a794addce0fe1604fa1b5ed663539f3:create

grant select on samqa.mypaymen to rl_sam1_ro;

grant select on samqa.mypaymen to rl_sam_rw;

grant select on samqa.mypaymen to rl_sam_ro;

grant select on samqa.mypaymen to sgali;

