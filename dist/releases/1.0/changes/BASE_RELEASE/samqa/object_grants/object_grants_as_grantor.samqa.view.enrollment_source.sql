-- liquibase formatted sql
-- changeset SAMQA:1754373943777 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.enrollment_source.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.enrollment_source.sql:null:6ff1edb1320c6a418f201b937e0dfee50228eade:create

grant select on samqa.enrollment_source to rl_sam1_ro;

grant select on samqa.enrollment_source to rl_sam_rw;

grant select on samqa.enrollment_source to rl_sam_ro;

grant select on samqa.enrollment_source to sgali;

