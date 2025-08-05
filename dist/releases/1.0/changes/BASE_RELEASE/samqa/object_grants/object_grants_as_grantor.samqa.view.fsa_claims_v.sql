-- liquibase formatted sql
-- changeset SAMQA:1754373943952 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_claims_v.sql:null:ee3282937e87f0a11bb3f6a8509b4e80c23aaa78:create

grant select on samqa.fsa_claims_v to rl_sam1_ro;

grant select on samqa.fsa_claims_v to rl_sam_rw;

grant select on samqa.fsa_claims_v to rl_sam_ro;

grant select on samqa.fsa_claims_v to sgali;

