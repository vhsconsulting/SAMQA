-- liquibase formatted sql
-- changeset SAMQA:1754373941246 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.monthly_new_rev_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.monthly_new_rev_report.sql:null:58b84ebb77b48c6b66b81e9bd427b1439bcd9f40:create

grant delete on samqa.monthly_new_rev_report to rl_sam_rw;

grant insert on samqa.monthly_new_rev_report to rl_sam_rw;

grant select on samqa.monthly_new_rev_report to rl_sam1_ro;

grant select on samqa.monthly_new_rev_report to rl_sam_ro;

grant select on samqa.monthly_new_rev_report to rl_sam_rw;

grant update on samqa.monthly_new_rev_report to rl_sam_rw;

