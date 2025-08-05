-- liquibase formatted sql
-- changeset SAMQA:1754373943246 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.cc_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.cc_type.sql:null:dedaba352dc0562670b2e49c0c0d0509f2b2e5a4:create

grant select on samqa.cc_type to rl_sam1_ro;

grant select on samqa.cc_type to rl_sam_rw;

grant select on samqa.cc_type to rl_sam_ro;

grant select on samqa.cc_type to sgali;

