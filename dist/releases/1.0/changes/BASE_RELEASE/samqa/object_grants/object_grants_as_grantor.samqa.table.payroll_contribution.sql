-- liquibase formatted sql
-- changeset SAMQA:1754373941637 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.payroll_contribution.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.payroll_contribution.sql:null:9a2709ba2ef8b68cfa3fa3b23c27907b02b25bd9:create

grant delete on samqa.payroll_contribution to rl_sam_rw;

grant insert on samqa.payroll_contribution to rl_sam_rw;

grant select on samqa.payroll_contribution to rl_sam1_ro;

grant select on samqa.payroll_contribution to rl_sam_rw;

grant select on samqa.payroll_contribution to rl_sam_ro;

grant update on samqa.payroll_contribution to rl_sam_rw;

