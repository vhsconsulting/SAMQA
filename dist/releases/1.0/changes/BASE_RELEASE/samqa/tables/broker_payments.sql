-- liquibase formatted sql
-- changeset SAMQA:1754374152668 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\broker_payments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/broker_payments.sql:null:6204a7c31c3b486ba5682addaa06a922778ad1fa:create

create table samqa.broker_payments (
    broker_payment_id  number,
    broker_id          number,
    vendor_id          number,
    bank_acct_id       number,
    transaction_number number,
    transaction_amount number,
    transaction_date   date,
    period_start_date  date,
    period_end_date    date,
    note               varchar2(3200 byte),
    creation_date      date default sysdate,
    created_by         number,
    last_update_date   date default sysdate,
    last_updated_by    number,
    account_type       varchar2(30 byte),
    reason_code        number,
    pay_code           number,
    check_number       varchar2(30 byte)
);

alter table samqa.broker_payments add primary key ( broker_payment_id )
    using index enable;

