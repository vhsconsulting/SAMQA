-- liquibase formatted sql
-- changeset SAMQA:1754373943544 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.edit_pending_hra_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.edit_pending_hra_claims_v.sql:null:1c84d3768a315f4f6deaa377c4df82f0acc36e19:create

grant select on samqa.edit_pending_hra_claims_v to rl_sam1_ro;

grant select on samqa.edit_pending_hra_claims_v to rl_sam_rw;

grant select on samqa.edit_pending_hra_claims_v to rl_sam_ro;

grant select on samqa.edit_pending_hra_claims_v to sgali;

