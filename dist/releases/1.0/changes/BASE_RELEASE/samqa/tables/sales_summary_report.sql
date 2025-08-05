-- liquibase formatted sql
-- changeset SAMQA:1754374162849 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\sales_summary_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/sales_summary_report.sql:null:213c554e7a877927aaf9a2dbfa8f993d141bdaf9:create

create table samqa.sales_summary_report (
    salesrep_id            number,
    salesrep               varchar2(255 byte),
    commissionable_revenue number,
    comm_percentage        number,
    commission_amount      number,
    ytd_revenue            number,
    start_date             date,
    end_date               date,
    insert_id              varchar2(10 byte)
);

