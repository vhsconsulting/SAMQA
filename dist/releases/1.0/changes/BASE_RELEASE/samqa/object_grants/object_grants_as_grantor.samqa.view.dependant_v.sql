-- liquibase formatted sql
-- changeset SAMQA:1754373943525 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.dependant_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.dependant_v.sql:null:d5183f9b92de4b7598ac13c0a0d68b69c5607c9e:create

grant select on samqa.dependant_v to rl_sam1_ro;

grant select on samqa.dependant_v to rl_sam_rw;

grant select on samqa.dependant_v to rl_sam_ro;

grant select on samqa.dependant_v to sgali;

