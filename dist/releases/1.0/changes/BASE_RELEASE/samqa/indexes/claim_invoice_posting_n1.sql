-- liquibase formatted sql
-- changeset SAMQA:1754373930324 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_invoice_posting_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_invoice_posting_n1.sql:null:bb17e9b55a2eeb8d7dcd919763cb094988ac83ac:create

create index samqa.claim_invoice_posting_n1 on
    samqa.claim_invoice_posting (
        claim_id
    );

