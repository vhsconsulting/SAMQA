-- liquibase formatted sql
-- changeset SAMQA:1754373942880 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.agc_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.agc_v.sql:null:87f776ec1fe3803e4bcb6e2e23951348f9f27101:create

grant select on samqa.agc_v to rl_sam1_ro;

grant select on samqa.agc_v to rl_sam_rw;

grant select on samqa.agc_v to rl_sam_ro;

grant select on samqa.agc_v to sgali;

