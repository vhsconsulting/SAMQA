-- liquibase formatted sql
-- changeset SAMQA:1754373943310 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.claim_metrics_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.claim_metrics_v.sql:null:66859447ba37f73ebf9679cc87280661f9441dd7:create

grant select on samqa.claim_metrics_v to rl_sam1_ro;

grant select on samqa.claim_metrics_v to rl_sam_rw;

grant select on samqa.claim_metrics_v to rl_sam_ro;

grant select on samqa.claim_metrics_v to sgali;

