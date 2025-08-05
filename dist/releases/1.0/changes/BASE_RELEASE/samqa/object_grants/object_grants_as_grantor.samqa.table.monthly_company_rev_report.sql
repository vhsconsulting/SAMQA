-- liquibase formatted sql
-- changeset SAMQA:1754373941214 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.monthly_company_rev_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.monthly_company_rev_report.sql:null:4f9aa85f0f6947ac4cb165c98fada0c3cdb95c97:create

grant delete on samqa.monthly_company_rev_report to rl_sam_rw;

grant insert on samqa.monthly_company_rev_report to rl_sam_rw;

grant select on samqa.monthly_company_rev_report to rl_sam1_ro;

grant select on samqa.monthly_company_rev_report to rl_sam_ro;

grant select on samqa.monthly_company_rev_report to rl_sam_rw;

grant update on samqa.monthly_company_rev_report to rl_sam_rw;

