-- liquibase formatted sql
-- changeset SAMQA:1754374160897 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\monthly_renewal_revenue_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/monthly_renewal_revenue_report.sql:null:2729f1c2f5b956c3d78b32730c6c984b990c1359:create

create table samqa.monthly_renewal_revenue_report (
    salesrep_id       number,
    salesrep          varchar2(255 byte),
    amount            number,
    group_name        varchar2(100 byte),
    account_type      varchar2(30 byte),
    invoice_id        number,
    period_start_date date,
    period_end_date   date,
    insert_id         varchar2(10 byte),
    creation_date     date,
    created_by        number,
    last_update_date  date,
    last_updated_by   number
);

