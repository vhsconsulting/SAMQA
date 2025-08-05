-- liquibase formatted sql
-- changeset SAMQA:1754374160856 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\monthly_new_rev_summary_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/monthly_new_rev_summary_report.sql:null:04240501e2f51be9a8ff98e96e4fcc6f77e7921c:create

create table samqa.monthly_new_rev_summary_report (
    approved          varchar2(30 byte),
    void              varchar2(30 byte),
    total_revenue     number,
    period_start_date date,
    period_end_date   date,
    insert_id         varchar2(10 byte)
);

