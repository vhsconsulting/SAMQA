-- liquibase formatted sql
-- changeset SAMQA:1754373943696 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.employer_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.employer_claims_v.sql:null:3e70481fe8f9f688fc3aa9aa5ca0bfb8b866440c:create

grant select on samqa.employer_claims_v to rl_sam1_ro;

grant select on samqa.employer_claims_v to rl_sam_rw;

grant select on samqa.employer_claims_v to rl_sam_ro;

grant select on samqa.employer_claims_v to sgali;

