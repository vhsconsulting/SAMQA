-- liquibase formatted sql
-- changeset SAMQA:1754373938704 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ar_invoice_contacts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ar_invoice_contacts.sql:null:e32f5df17e114950920a0f6e5aa16c45e7d3ae69:create

grant delete on samqa.ar_invoice_contacts to rl_sam_rw;

grant insert on samqa.ar_invoice_contacts to rl_sam_rw;

grant select on samqa.ar_invoice_contacts to rl_sam1_ro;

grant select on samqa.ar_invoice_contacts to rl_sam_rw;

grant select on samqa.ar_invoice_contacts to rl_sam_ro;

grant update on samqa.ar_invoice_contacts to rl_sam_rw;

