-- liquibase formatted sql
-- changeset SAMQA:1754373940646 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.gp_fee_result_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.gp_fee_result_external.sql:null:74d9341d989ab5a94b79de04c123a752063b3997:create

grant select on samqa.gp_fee_result_external to rl_sam1_ro;

grant select on samqa.gp_fee_result_external to rl_sam_ro;

