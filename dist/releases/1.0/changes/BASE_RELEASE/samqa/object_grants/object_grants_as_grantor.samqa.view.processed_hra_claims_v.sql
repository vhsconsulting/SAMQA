-- liquibase formatted sql
-- changeset SAMQA:1754373945000 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.processed_hra_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.processed_hra_claims_v.sql:null:26eb8487819c9b6f3cba40a7e2b92a3c14fb3b97:create

grant select on samqa.processed_hra_claims_v to rl_sam1_ro;

grant select on samqa.processed_hra_claims_v to rl_sam_rw;

grant select on samqa.processed_hra_claims_v to rl_sam_ro;

grant select on samqa.processed_hra_claims_v to sgali;

