-- liquibase formatted sql
-- changeset SAMQA:1754373939358 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.claim_reconcile_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.claim_reconcile_external.sql:null:080b52c0173bab1c642f621f8071c1ca6683357a:create

grant select on samqa.claim_reconcile_external to rl_sam1_ro;

grant select on samqa.claim_reconcile_external to rl_sam_ro;

