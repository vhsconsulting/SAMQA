-- liquibase formatted sql
-- changeset SAMQA:1754373942927 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.audit_invoices_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.audit_invoices_v.sql:null:c06dfc4766e8d01953ccb9e00502d0c952599ac9:create

grant select on samqa.audit_invoices_v to rl_sam1_ro;

grant select on samqa.audit_invoices_v to rl_sam_rw;

grant select on samqa.audit_invoices_v to rl_sam_ro;

grant select on samqa.audit_invoices_v to sgali;

