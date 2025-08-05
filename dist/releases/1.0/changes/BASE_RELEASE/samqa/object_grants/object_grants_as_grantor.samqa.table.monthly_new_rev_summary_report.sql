-- liquibase formatted sql
-- changeset SAMQA:1754373941259 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.monthly_new_rev_summary_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.monthly_new_rev_summary_report.sql:null:c84a530e4e71c0b96ec21f15c6e37c12adbec419:create

grant delete on samqa.monthly_new_rev_summary_report to rl_sam_rw;

grant insert on samqa.monthly_new_rev_summary_report to rl_sam_rw;

grant select on samqa.monthly_new_rev_summary_report to rl_sam1_ro;

grant select on samqa.monthly_new_rev_summary_report to rl_sam_ro;

grant select on samqa.monthly_new_rev_summary_report to rl_sam_rw;

grant update on samqa.monthly_new_rev_summary_report to rl_sam_rw;

