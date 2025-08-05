-- liquibase formatted sql
-- changeset SAMQA:1754374160869 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\monthly_new_revenue_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/monthly_new_revenue_report.sql:null:121e938b5bacc1da74420f33bf302583099df95b:create

create table samqa.monthly_new_revenue_report (
    salesrep_id       number,
    salesrep          varchar2(255 byte),
    amount            number,
    group_name        varchar2(100 byte),
    account_type      varchar2(30 byte),
    period_start_date date,
    period_end_date   date,
    insert_id         varchar2(10 byte),
    creation_date     date,
    created_by        number,
    last_update_date  date,
    last_updated_by   number,
    invoice_id        number,
    acc_id            number
);

