-- liquibase formatted sql
-- changeset SAMQA:1754373943262 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.claim_checks_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.claim_checks_v.sql:null:e48c3a445f7352273014ea6d13611b4573525047:create

grant select on samqa.claim_checks_v to rl_sam1_ro;

grant select on samqa.claim_checks_v to rl_sam_rw;

grant select on samqa.claim_checks_v to rl_sam_ro;

grant select on samqa.claim_checks_v to sgali;

