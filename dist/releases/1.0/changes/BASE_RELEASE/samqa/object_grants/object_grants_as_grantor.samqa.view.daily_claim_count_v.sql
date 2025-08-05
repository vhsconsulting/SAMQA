-- liquibase formatted sql
-- changeset SAMQA:1754373943482 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.daily_claim_count_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.daily_claim_count_v.sql:null:666c72b0468d441352f50a7a83b7d5bd2f841d42:create

grant select on samqa.daily_claim_count_v to rl_sam1_ro;

grant select on samqa.daily_claim_count_v to rl_sam_rw;

grant select on samqa.daily_claim_count_v to rl_sam_ro;

grant select on samqa.daily_claim_count_v to sgali;

