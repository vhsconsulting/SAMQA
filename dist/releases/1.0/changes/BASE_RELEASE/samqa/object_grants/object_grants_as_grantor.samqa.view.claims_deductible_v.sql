-- liquibase formatted sql
-- changeset SAMQA:1754373943357 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.claims_deductible_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.claims_deductible_v.sql:null:506992977075f3a69f6c1d8fa09eb3d4c9ca7bb8:create

grant select on samqa.claims_deductible_v to rl_sam1_ro;

grant select on samqa.claims_deductible_v to rl_sam_rw;

grant select on samqa.claims_deductible_v to rl_sam_ro;

grant select on samqa.claims_deductible_v to sgali;

