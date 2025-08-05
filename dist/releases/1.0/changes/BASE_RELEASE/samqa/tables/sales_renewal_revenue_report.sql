-- liquibase formatted sql
-- changeset SAMQA:1754374162833 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\sales_renewal_revenue_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/sales_renewal_revenue_report.sql:null:aaf94176818ac77e17c5ed4ae909045d6ca5247a:create

create table samqa.sales_renewal_revenue_report (
    ytd_revenue_amount number,
    last_update_date   date
);

