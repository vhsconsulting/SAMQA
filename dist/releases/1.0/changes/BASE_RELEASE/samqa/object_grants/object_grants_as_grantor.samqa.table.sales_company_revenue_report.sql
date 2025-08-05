-- liquibase formatted sql
-- changeset SAMQA:1754373941933 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.sales_company_revenue_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.sales_company_revenue_report.sql:null:999481a3c1c104ead0ffaf875b7f2e185ba63072:create

grant delete on samqa.sales_company_revenue_report to rl_sam_rw;

grant insert on samqa.sales_company_revenue_report to rl_sam_rw;

grant select on samqa.sales_company_revenue_report to rl_sam1_ro;

grant select on samqa.sales_company_revenue_report to rl_sam_ro;

grant select on samqa.sales_company_revenue_report to rl_sam_rw;

grant update on samqa.sales_company_revenue_report to rl_sam_rw;

