-- liquibase formatted sql
-- changeset SAMQA:1754373943537 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.edit_pending_fsa_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.edit_pending_fsa_claims_v.sql:null:f2f2ac7a928f8e7600647c0cdd138c70958056bf:create

grant select on samqa.edit_pending_fsa_claims_v to rl_sam1_ro;

grant select on samqa.edit_pending_fsa_claims_v to rl_sam_rw;

grant select on samqa.edit_pending_fsa_claims_v to rl_sam_ro;

grant select on samqa.edit_pending_fsa_claims_v to sgali;

