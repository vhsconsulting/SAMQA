-- liquibase formatted sql
-- changeset SAMQA:1754373945353 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.ui_invoice_query_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.ui_invoice_query_v.sql:null:1ebaf42cc0ae0b4d72c603141d473a48cf390247:create

grant select on samqa.ui_invoice_query_v to rl_sam_ro;

