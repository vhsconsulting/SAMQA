-- liquibase formatted sql
-- changeset SAMQA:1754374160908 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\monthly_rwl_rev_summary_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/monthly_rwl_rev_summary_report.sql:null:5f6dfcaa86d36c9f080ee35e4059679d35e72b84:create

create table samqa.monthly_rwl_rev_summary_report (
    approved          varchar2(30 byte),
    void              varchar2(30 byte),
    total_revenue     number,
    period_start_date date,
    period_end_date   date,
    insert_id         varchar2(10 byte)
);

