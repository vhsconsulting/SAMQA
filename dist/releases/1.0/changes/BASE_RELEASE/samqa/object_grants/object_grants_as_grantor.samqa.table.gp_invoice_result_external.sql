-- liquibase formatted sql
-- changeset SAMQA:1754373940664 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.gp_invoice_result_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.gp_invoice_result_external.sql:null:8d41c79ece39227fc6de4f261c71a6f16a155a5a:create

grant select on samqa.gp_invoice_result_external to rl_sam1_ro;

grant select on samqa.gp_invoice_result_external to rl_sam_ro;

