-- liquibase formatted sql
-- changeset SAMQA:1754373931603 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\i_sales_commission_report_prm.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/i_sales_commission_report_prm.sql:null:562d3fefcb8ad7873424012c0293a6f816dbefb3:create

create index samqa.i_sales_commission_report_prm on
    samqa.sales_commission_report (
        account_type,
        salesrep_id,
        period_start_date,
        period_end_date
    );

