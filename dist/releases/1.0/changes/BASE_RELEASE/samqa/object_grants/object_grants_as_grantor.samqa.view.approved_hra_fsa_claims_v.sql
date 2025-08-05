-- liquibase formatted sql
-- changeset SAMQA:1754373942911 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.approved_hra_fsa_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.approved_hra_fsa_claims_v.sql:null:3d361e36948218dd835ff8b5bfb5c4d590af5890:create

grant select on samqa.approved_hra_fsa_claims_v to rl_sam1_ro;

grant select on samqa.approved_hra_fsa_claims_v to rl_sam_rw;

grant select on samqa.approved_hra_fsa_claims_v to rl_sam_ro;

grant select on samqa.approved_hra_fsa_claims_v to sgali;

