-- liquibase formatted sql
-- changeset SAMQA:1754373939353 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.claim_receipts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.claim_receipts.sql:null:7c4457ae3612512a1a69f9cabf6912fbf0ad010c:create

grant delete on samqa.claim_receipts to rl_sam_rw;

grant insert on samqa.claim_receipts to rl_sam_rw;

grant select on samqa.claim_receipts to rl_sam1_ro;

grant select on samqa.claim_receipts to rl_sam_ro;

grant select on samqa.claim_receipts to rl_sam_rw;

grant update on samqa.claim_receipts to rl_sam_rw;

