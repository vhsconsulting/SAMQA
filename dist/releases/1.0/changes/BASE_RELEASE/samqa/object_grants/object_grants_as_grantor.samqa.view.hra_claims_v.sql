-- liquibase formatted sql
-- changeset SAMQA:1754373944235 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.hra_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.hra_claims_v.sql:null:72cde353b81566039ba730ccda8a132202caf8fc:create

grant select on samqa.hra_claims_v to rl_sam1_ro;

grant select on samqa.hra_claims_v to rl_sam_rw;

grant select on samqa.hra_claims_v to rl_sam_ro;

grant select on samqa.hra_claims_v to sgali;

