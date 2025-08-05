-- liquibase formatted sql
-- changeset SAMQA:1754373939345 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.claim_invoice_posting.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.claim_invoice_posting.sql:null:2587c5117307b22b5c831d4dc4e12726476ff70b:create

grant delete on samqa.claim_invoice_posting to rl_sam_rw;

grant insert on samqa.claim_invoice_posting to rl_sam_rw;

grant select on samqa.claim_invoice_posting to rl_sam1_ro;

grant select on samqa.claim_invoice_posting to rl_sam_rw;

grant select on samqa.claim_invoice_posting to rl_sam_ro;

grant update on samqa.claim_invoice_posting to rl_sam_rw;

