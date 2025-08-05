-- liquibase formatted sql
-- changeset SAMQA:1754373943681 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.employees_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.employees_v.sql:null:84b7fc62de707fba25f8c2531e128159575ed08b:create

grant select on samqa.employees_v to rl_sam1_ro;

grant select on samqa.employees_v to rl_sam_rw;

grant select on samqa.employees_v to rl_sam_ro;

grant select on samqa.employees_v to sgali;

