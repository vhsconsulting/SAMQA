-- liquibase formatted sql
-- changeset SAMQA:1754373938728 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ar_invoice_notifications.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ar_invoice_notifications.sql:null:72b2fc456f1bb23d76d24c170e6cbc74de10b8db:create

grant delete on samqa.ar_invoice_notifications to rl_sam_rw;

grant insert on samqa.ar_invoice_notifications to rl_sam_rw;

grant select on samqa.ar_invoice_notifications to rl_sam1_ro;

grant select on samqa.ar_invoice_notifications to rl_sam_rw;

grant select on samqa.ar_invoice_notifications to rl_sam_ro;

grant select on samqa.ar_invoice_notifications to reportdb_ro;

grant update on samqa.ar_invoice_notifications to rl_sam_rw;

