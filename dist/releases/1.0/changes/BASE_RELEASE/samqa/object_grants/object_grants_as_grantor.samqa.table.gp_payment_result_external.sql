-- liquibase formatted sql
-- changeset SAMQA:1754373940673 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.gp_payment_result_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.gp_payment_result_external.sql:null:d484a05fcab1c679036984ed96ab781486627403:create

grant select on samqa.gp_payment_result_external to rl_sam1_ro;

grant select on samqa.gp_payment_result_external to rl_sam_ro;

