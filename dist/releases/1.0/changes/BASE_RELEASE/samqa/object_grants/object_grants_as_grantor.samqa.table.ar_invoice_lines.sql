-- liquibase formatted sql
-- changeset SAMQA:1754373938720 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ar_invoice_lines.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ar_invoice_lines.sql:null:6a457ea2f10fcc25fa351448fc45b404abaa3ff6:create

grant delete on samqa.ar_invoice_lines to rl_sam_rw;

grant insert on samqa.ar_invoice_lines to rl_sam_rw;

grant select on samqa.ar_invoice_lines to rl_sam1_ro;

grant select on samqa.ar_invoice_lines to rl_sam_rw;

grant select on samqa.ar_invoice_lines to rl_sam_ro;

grant select on samqa.ar_invoice_lines to reportdb_ro;

grant update on samqa.ar_invoice_lines to rl_sam_rw;

