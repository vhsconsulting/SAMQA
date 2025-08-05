-- liquibase formatted sql
-- changeset SAMQA:1754373943166 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.cancelled_fsa_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.cancelled_fsa_claims_v.sql:null:eebf6d5297f0b00a0edb46cfd55111d5a6b924f1:create

grant select on samqa.cancelled_fsa_claims_v to rl_sam1_ro;

grant select on samqa.cancelled_fsa_claims_v to rl_sam_rw;

grant select on samqa.cancelled_fsa_claims_v to rl_sam_ro;

grant select on samqa.cancelled_fsa_claims_v to sgali;

