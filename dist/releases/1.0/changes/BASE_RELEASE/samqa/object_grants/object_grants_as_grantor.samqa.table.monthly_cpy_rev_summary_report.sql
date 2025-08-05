-- liquibase formatted sql
-- changeset SAMQA:1754373941214 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.monthly_cpy_rev_summary_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.monthly_cpy_rev_summary_report.sql:null:f5e59cdc99c6d92bd38ab2171de2a13d46344285:create

grant delete on samqa.monthly_cpy_rev_summary_report to rl_sam_rw;

grant insert on samqa.monthly_cpy_rev_summary_report to rl_sam_rw;

grant select on samqa.monthly_cpy_rev_summary_report to rl_sam1_ro;

grant select on samqa.monthly_cpy_rev_summary_report to rl_sam_ro;

grant select on samqa.monthly_cpy_rev_summary_report to rl_sam_rw;

grant update on samqa.monthly_cpy_rev_summary_report to rl_sam_rw;

