-- liquibase formatted sql
-- changeset SAMQA:1754373937485 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.claim_invoice_posting_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.claim_invoice_posting_seq.sql:null:5f4295f053ad999ee91b1e1707735be1de5e73d1:create

grant select on samqa.claim_invoice_posting_seq to rl_sam_rw;

