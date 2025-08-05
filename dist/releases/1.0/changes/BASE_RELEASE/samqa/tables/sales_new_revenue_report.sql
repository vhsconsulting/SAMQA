-- liquibase formatted sql
-- changeset SAMQA:1754374162833 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\sales_new_revenue_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/sales_new_revenue_report.sql:null:bf8f113af53274fa1ddc514ae0ca9b763ccc2431:create

create table samqa.sales_new_revenue_report (
    ytd_revenue_amount number,
    last_update_date   date
);

