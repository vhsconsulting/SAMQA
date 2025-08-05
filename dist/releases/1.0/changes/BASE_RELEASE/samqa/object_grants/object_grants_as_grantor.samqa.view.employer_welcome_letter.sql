-- liquibase formatted sql
-- changeset SAMQA:1754373943733 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.employer_welcome_letter.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.employer_welcome_letter.sql:null:1395a80bd9ae90a248262d5856296555a1bf1e78:create

grant select on samqa.employer_welcome_letter to rl_sam1_ro;

grant select on samqa.employer_welcome_letter to rl_sam_rw;

grant select on samqa.employer_welcome_letter to rl_sam_ro;

grant select on samqa.employer_welcome_letter to sgali;

