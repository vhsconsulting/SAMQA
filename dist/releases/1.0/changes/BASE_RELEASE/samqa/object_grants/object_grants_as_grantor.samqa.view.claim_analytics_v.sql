-- liquibase formatted sql
-- changeset SAMQA:1754373943262 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.claim_analytics_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.claim_analytics_v.sql:null:427d6e4741c239a1d87f1663733c5fd200b23102:create

grant select on samqa.claim_analytics_v to rl_sam1_ro;

grant select on samqa.claim_analytics_v to rl_sam_rw;

grant select on samqa.claim_analytics_v to rl_sam_ro;

grant select on samqa.claim_analytics_v to sgali;

