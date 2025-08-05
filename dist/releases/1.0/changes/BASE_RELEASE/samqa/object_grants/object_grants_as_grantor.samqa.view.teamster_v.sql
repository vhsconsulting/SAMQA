-- liquibase formatted sql
-- changeset SAMQA:1754373945275 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.teamster_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.teamster_v.sql:null:9f7d1087e7a71679bfec11876a60b4767ec8155f:create

grant select on samqa.teamster_v to rl_sam_rw;

grant select on samqa.teamster_v to rl_sam_ro;

grant select on samqa.teamster_v to sgali;

grant select on samqa.teamster_v to rl_sam1_ro;

