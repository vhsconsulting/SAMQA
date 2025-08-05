-- liquibase formatted sql
-- changeset SAMQA:1754373939727 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.deductible_rule_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.deductible_rule_detail.sql:null:716b3cac1151da9b21cfb23a45983026210a6c53:create

grant delete on samqa.deductible_rule_detail to rl_sam_rw;

grant insert on samqa.deductible_rule_detail to rl_sam_rw;

grant select on samqa.deductible_rule_detail to rl_sam1_ro;

grant select on samqa.deductible_rule_detail to rl_sam_rw;

grant select on samqa.deductible_rule_detail to rl_sam_ro;

grant update on samqa.deductible_rule_detail to rl_sam_rw;

