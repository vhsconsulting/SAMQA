-- liquibase formatted sql
-- changeset SAMQA:1754373939717 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.deductible_rule.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.deductible_rule.sql:null:d487fed96e6ce78d8ea482c0a12b7c6e02740eba:create

grant delete on samqa.deductible_rule to rl_sam_rw;

grant insert on samqa.deductible_rule to rl_sam_rw;

grant select on samqa.deductible_rule to rl_sam1_ro;

grant select on samqa.deductible_rule to rl_sam_rw;

grant select on samqa.deductible_rule to rl_sam_ro;

grant update on samqa.deductible_rule to rl_sam_rw;

