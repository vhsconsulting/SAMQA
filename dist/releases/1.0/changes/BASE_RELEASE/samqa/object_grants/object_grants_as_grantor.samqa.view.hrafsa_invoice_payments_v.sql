-- liquibase formatted sql
-- changeset SAMQA:1754373944355 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.hrafsa_invoice_payments_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.hrafsa_invoice_payments_v.sql:null:4ef75f727087e73764b8248b9568bb3ff15a5c68:create

grant select on samqa.hrafsa_invoice_payments_v to rl_sam1_ro;

grant select on samqa.hrafsa_invoice_payments_v to rl_sam_rw;

grant select on samqa.hrafsa_invoice_payments_v to rl_sam_ro;

grant select on samqa.hrafsa_invoice_payments_v to sgali;

