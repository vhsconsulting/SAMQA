-- liquibase formatted sql
-- changeset SAMQA:1754373941951 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.sales_renewal_revenue_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.sales_renewal_revenue_report.sql:null:0c7311dc87e16baae378fff3485c23cb42149bb2:create

grant delete on samqa.sales_renewal_revenue_report to rl_sam_rw;

grant insert on samqa.sales_renewal_revenue_report to rl_sam_rw;

grant select on samqa.sales_renewal_revenue_report to rl_sam1_ro;

grant select on samqa.sales_renewal_revenue_report to rl_sam_ro;

grant select on samqa.sales_renewal_revenue_report to rl_sam_rw;

grant update on samqa.sales_renewal_revenue_report to rl_sam_rw;

