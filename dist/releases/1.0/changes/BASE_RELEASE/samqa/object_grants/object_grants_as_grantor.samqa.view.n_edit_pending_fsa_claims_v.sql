-- liquibase formatted sql
-- changeset SAMQA:1754373944699 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.n_edit_pending_fsa_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.n_edit_pending_fsa_claims_v.sql:null:7e1b856b4d2f1785ac1eab97ffaa154ae61f01d7:create

grant select on samqa.n_edit_pending_fsa_claims_v to rl_sam1_ro;

grant select on samqa.n_edit_pending_fsa_claims_v to rl_sam_rw;

grant select on samqa.n_edit_pending_fsa_claims_v to rl_sam_ro;

grant select on samqa.n_edit_pending_fsa_claims_v to sgali;

