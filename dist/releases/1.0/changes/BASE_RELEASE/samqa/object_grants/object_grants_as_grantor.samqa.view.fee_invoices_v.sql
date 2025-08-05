-- liquibase formatted sql
-- changeset SAMQA:1754373943913 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fee_invoices_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fee_invoices_v.sql:null:ce71009cfc8140dcc14e082cc7a77ad14c735790:create

grant select on samqa.fee_invoices_v to rl_sam1_ro;

grant select on samqa.fee_invoices_v to rl_sam_rw;

grant select on samqa.fee_invoices_v to rl_sam_ro;

grant select on samqa.fee_invoices_v to sgali;

