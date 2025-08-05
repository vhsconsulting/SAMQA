-- liquibase formatted sql
-- changeset SAMQA:1754374151862 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\balance_register.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/balance_register.sql:null:e22dec444a99cf3056aa896615cec103fc70c945:create

create table samqa.balance_register (
    register_id number not null enable,
    acc_id      number,
    fee_date    date,
    reason_code varchar2(500 byte),
    note        varchar2(3200 byte),
    amount      number,
    reason_mode varchar2(10 byte),
    change_id   number,
    plan_type   varchar2(30 byte),
        txn_date    date generated always as ( trunc(fee_date) ) virtual
);

alter table samqa.balance_register
    add constraint balance_register_pk primary key ( register_id )
        using index enable;

