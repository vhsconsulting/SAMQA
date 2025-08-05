-- liquibase formatted sql
-- changeset SAMQA:1754374147939 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\claim_invoice_posting_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/claim_invoice_posting_seq.sql:null:452e72cd16aa38633ca7f6c22b9d414ae44e4269:create

create sequence samqa.claim_invoice_posting_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 351236 cache
20 noorder nocycle nokeep noscale global;

