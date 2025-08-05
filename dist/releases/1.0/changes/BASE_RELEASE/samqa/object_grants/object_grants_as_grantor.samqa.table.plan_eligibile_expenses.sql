-- liquibase formatted sql
-- changeset SAMQA:1754373941684 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.plan_eligibile_expenses.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.plan_eligibile_expenses.sql:null:aa136b7b1af7d0d3655a8730dd7a08121c1ed474:create

grant delete on samqa.plan_eligibile_expenses to rl_sam_rw;

grant insert on samqa.plan_eligibile_expenses to rl_sam_rw;

grant select on samqa.plan_eligibile_expenses to rl_sam1_ro;

grant select on samqa.plan_eligibile_expenses to rl_sam_rw;

grant select on samqa.plan_eligibile_expenses to rl_sam_ro;

grant update on samqa.plan_eligibile_expenses to rl_sam_rw;

