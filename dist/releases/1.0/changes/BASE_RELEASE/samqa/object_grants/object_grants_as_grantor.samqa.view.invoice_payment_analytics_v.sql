-- liquibase formatted sql
-- changeset SAMQA:1754373944477 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.invoice_payment_analytics_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.invoice_payment_analytics_v.sql:null:f7b709f255ab38571462a1fc06d4b5b2d5500665:create

grant select on samqa.invoice_payment_analytics_v to rl_sam1_ro;

grant select on samqa.invoice_payment_analytics_v to rl_sam_rw;

grant select on samqa.invoice_payment_analytics_v to rl_sam_ro;

grant select on samqa.invoice_payment_analytics_v to sgali;

