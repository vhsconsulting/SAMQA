-- liquibase formatted sql
-- changeset SAMQA:1754374162817 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\sales_company_revenue_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/sales_company_revenue_report.sql:null:73c6a9761984591646cc3be31b6a232a6092d00c:create

create table samqa.sales_company_revenue_report (
    ytd_revenue_amount number,
    last_update_date   date
);

