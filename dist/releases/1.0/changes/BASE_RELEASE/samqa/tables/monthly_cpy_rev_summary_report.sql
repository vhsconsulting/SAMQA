-- liquibase formatted sql
-- changeset SAMQA:1754374160790 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\monthly_cpy_rev_summary_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/monthly_cpy_rev_summary_report.sql:null:32ce5686747128e460aa88de8f7febb963563ebe:create

create table samqa.monthly_cpy_rev_summary_report (
    approved          varchar2(30 byte),
    void              varchar2(30 byte),
    total_revenue     number,
    period_start_date date,
    period_end_date   date,
    insert_id         varchar2(10 byte)
);

