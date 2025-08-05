-- liquibase formatted sql
-- changeset SAMQA:1754373941278 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.monthly_rwl_rev_summary_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.monthly_rwl_rev_summary_report.sql:null:3f987d98250526df5752ce69e55ff0eb36adcea7:create

grant delete on samqa.monthly_rwl_rev_summary_report to rl_sam_rw;

grant insert on samqa.monthly_rwl_rev_summary_report to rl_sam_rw;

grant select on samqa.monthly_rwl_rev_summary_report to rl_sam1_ro;

grant select on samqa.monthly_rwl_rev_summary_report to rl_sam_ro;

grant select on samqa.monthly_rwl_rev_summary_report to rl_sam_rw;

grant update on samqa.monthly_rwl_rev_summary_report to rl_sam_rw;

