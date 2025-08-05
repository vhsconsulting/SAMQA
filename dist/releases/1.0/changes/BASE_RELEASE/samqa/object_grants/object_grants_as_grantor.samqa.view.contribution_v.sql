-- liquibase formatted sql
-- changeset SAMQA:1754373943420 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.contribution_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.contribution_v.sql:null:a77f90d905d4e7daaa5b152c9deb72dde32bfca6:create

grant select on samqa.contribution_v to rl_sam1_ro;

grant select on samqa.contribution_v to rl_sam_rw;

grant select on samqa.contribution_v to rl_sam_ro;

grant select on samqa.contribution_v to sgali;

