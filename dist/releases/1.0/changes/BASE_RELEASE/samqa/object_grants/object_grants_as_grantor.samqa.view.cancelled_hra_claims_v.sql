-- liquibase formatted sql
-- changeset SAMQA:1754373943182 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.cancelled_hra_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.cancelled_hra_claims_v.sql:null:e3fa14da5183ac4f23f30313ba812505866c51a0:create

grant select on samqa.cancelled_hra_claims_v to rl_sam1_ro;

grant select on samqa.cancelled_hra_claims_v to rl_sam_rw;

grant select on samqa.cancelled_hra_claims_v to rl_sam_ro;

grant select on samqa.cancelled_hra_claims_v to sgali;

