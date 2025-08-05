-- liquibase formatted sql
-- changeset SAMQA:1754373940659 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.gp_invoice_error_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.gp_invoice_error_external.sql:null:e0ceb2f6164dde7fbe51d21c6d1e7b029592c931:create

grant select on samqa.gp_invoice_error_external to rl_sam1_ro;

grant select on samqa.gp_invoice_error_external to rl_sam_ro;

