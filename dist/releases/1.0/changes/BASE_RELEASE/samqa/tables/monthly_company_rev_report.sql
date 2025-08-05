-- liquibase formatted sql
-- changeset SAMQA:1754374160780 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\monthly_company_rev_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/monthly_company_rev_report.sql:null:6fc7da338a0e10ed32ab5a901dfa2d61d0ed3806:create

create table samqa.monthly_company_rev_report (
    salesrep_id         number,
    salesrep            varchar2(255 byte),
    amount              number,
    group_name          varchar2(255 byte),
    account_type        varchar2(30 byte),
    period_start_date   date,
    period_end_date     date,
    insert_id           varchar2(10 byte),
    creation_date       date,
    created_by          number,
    last_update_date    date,
    last_updated_by     number,
    invoice_id          number,
    invoice_status      varchar2(30 byte),
    invoice_line_status varchar2(30 byte)
);

