-- liquibase formatted sql
-- changeset SAMQA:1754373941264 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.monthly_renewal_rev_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.monthly_renewal_rev_report.sql:null:90f7d90d5bcb72faf59a389c825d784a173f033b:create

grant delete on samqa.monthly_renewal_rev_report to rl_sam_rw;

grant insert on samqa.monthly_renewal_rev_report to rl_sam_rw;

grant select on samqa.monthly_renewal_rev_report to rl_sam1_ro;

grant select on samqa.monthly_renewal_rev_report to rl_sam_ro;

grant select on samqa.monthly_renewal_rev_report to rl_sam_rw;

grant update on samqa.monthly_renewal_rev_report to rl_sam_rw;

