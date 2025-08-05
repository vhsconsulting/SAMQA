-- liquibase formatted sql
-- changeset SAMQA:1754373940678 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.gp_receipt_error_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.gp_receipt_error_external.sql:null:a7634e9768ad9b8548e52b02f7ea726532631220:create

grant select on samqa.gp_receipt_error_external to rl_sam1_ro;

grant select on samqa.gp_receipt_error_external to rl_sam_ro;

