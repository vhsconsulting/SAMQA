-- liquibase formatted sql
-- changeset SAMQA:1754373944709 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.n_edit_pending_hra_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.n_edit_pending_hra_claims_v.sql:null:d7e577a3a02daf0ba928c5dd2a651702319b4436:create

grant select on samqa.n_edit_pending_hra_claims_v to rl_sam1_ro;

grant select on samqa.n_edit_pending_hra_claims_v to rl_sam_rw;

grant select on samqa.n_edit_pending_hra_claims_v to rl_sam_ro;

grant select on samqa.n_edit_pending_hra_claims_v to sgali;

