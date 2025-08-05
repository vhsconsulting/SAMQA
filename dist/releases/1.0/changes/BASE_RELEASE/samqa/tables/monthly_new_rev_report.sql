-- liquibase formatted sql
-- changeset SAMQA:1754374160845 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\monthly_new_rev_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/monthly_new_rev_report.sql:null:6e7a811b0234c7b59cb0d2188f500550e30dac9e:create

create table samqa.monthly_new_rev_report (
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
    invoice_line_status varchar2(30 byte),
    reason_code         number,
    acc_id              number
);

