-- liquibase formatted sql
-- changeset SAMQA:1754373937072 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.refund_claim_invoice.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.refund_claim_invoice.sql:null:03672714615acef0a58c7b423ec156ea108a8522:create

grant execute on samqa.refund_claim_invoice to rl_sam_rw;

grant execute on samqa.refund_claim_invoice to rl_sam_ro;

grant execute on samqa.refund_claim_invoice to rl_sam1_ro;

grant debug on samqa.refund_claim_invoice to sgali;

grant debug on samqa.refund_claim_invoice to rl_sam_rw;

grant debug on samqa.refund_claim_invoice to rl_sam1_ro;

