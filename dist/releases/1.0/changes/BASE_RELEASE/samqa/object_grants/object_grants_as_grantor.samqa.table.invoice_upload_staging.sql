-- liquibase formatted sql
-- changeset SAMQA:1754373940912 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.invoice_upload_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.invoice_upload_staging.sql:null:120fb916d3ee3b4e6de9753b76a47f9643489ab2:create

grant alter on samqa.invoice_upload_staging to shavee;

grant delete on samqa.invoice_upload_staging to rl_sam_rw;

grant delete on samqa.invoice_upload_staging to shavee;

grant index on samqa.invoice_upload_staging to shavee;

grant insert on samqa.invoice_upload_staging to rl_sam_rw;

grant insert on samqa.invoice_upload_staging to shavee;

grant select on samqa.invoice_upload_staging to rl_sam1_ro;

grant select on samqa.invoice_upload_staging to rl_sam_ro;

grant select on samqa.invoice_upload_staging to rl_sam_rw;

grant select on samqa.invoice_upload_staging to shavee;

grant update on samqa.invoice_upload_staging to rl_sam_rw;

grant update on samqa.invoice_upload_staging to shavee;

grant references on samqa.invoice_upload_staging to shavee;

grant read on samqa.invoice_upload_staging to shavee;

grant on commit refresh on samqa.invoice_upload_staging to shavee;

grant query rewrite on samqa.invoice_upload_staging to shavee;

grant debug on samqa.invoice_upload_staging to shavee;

grant flashback on samqa.invoice_upload_staging to shavee;

