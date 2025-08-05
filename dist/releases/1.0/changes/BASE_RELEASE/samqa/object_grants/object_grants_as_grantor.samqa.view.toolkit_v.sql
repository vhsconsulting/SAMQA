-- liquibase formatted sql
-- changeset SAMQA:1754373945346 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.toolkit_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.toolkit_v.sql:null:76615655fe67ea9c85b1295a9a664f45211acea7:create

grant select on samqa.toolkit_v to rl_sam_rw;

grant select on samqa.toolkit_v to rl_sam_ro;

grant select on samqa.toolkit_v to sgali;

grant select on samqa.toolkit_v to rl_sam1_ro;

