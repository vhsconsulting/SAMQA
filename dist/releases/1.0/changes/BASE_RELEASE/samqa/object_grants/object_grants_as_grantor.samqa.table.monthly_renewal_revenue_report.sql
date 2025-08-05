-- liquibase formatted sql
-- changeset SAMQA:1754373941278 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.monthly_renewal_revenue_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.monthly_renewal_revenue_report.sql:null:a274c77c6718ac068df62fbf71834949342d78f0:create

grant delete on samqa.monthly_renewal_revenue_report to rl_sam_rw;

grant insert on samqa.monthly_renewal_revenue_report to rl_sam_rw;

grant select on samqa.monthly_renewal_revenue_report to rl_sam1_ro;

grant select on samqa.monthly_renewal_revenue_report to rl_sam_ro;

grant select on samqa.monthly_renewal_revenue_report to rl_sam_rw;

grant update on samqa.monthly_renewal_revenue_report to rl_sam_rw;

