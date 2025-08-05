-- liquibase formatted sql
-- changeset SAMQA:1754373941229 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.monthly_invoice_payment_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.monthly_invoice_payment_detail.sql:null:1e848803f44d3b5aab4c018a6a352a500df37605:create

grant delete on samqa.monthly_invoice_payment_detail to rl_sam_rw;

grant insert on samqa.monthly_invoice_payment_detail to rl_sam_rw;

grant select on samqa.monthly_invoice_payment_detail to rl_sam1_ro;

grant select on samqa.monthly_invoice_payment_detail to rl_sam_ro;

grant select on samqa.monthly_invoice_payment_detail to rl_sam_rw;

grant update on samqa.monthly_invoice_payment_detail to rl_sam_rw;

