-- liquibase formatted sql
-- changeset SAMQA:1754373944875 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.pending_hra_fsa_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.pending_hra_fsa_claims_v.sql:null:63a815ee6a149ab9b221b9304791dfa4fa2aca5d:create

grant select on samqa.pending_hra_fsa_claims_v to rl_sam_ro;

grant select on samqa.pending_hra_fsa_claims_v to sgali;

grant select on samqa.pending_hra_fsa_claims_v to rl_sam1_ro;

grant select on samqa.pending_hra_fsa_claims_v to rl_sam_rw;

