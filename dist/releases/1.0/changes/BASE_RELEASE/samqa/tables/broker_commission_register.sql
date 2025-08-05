-- liquibase formatted sql
-- changeset SAMQA:1754374152628 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\broker_commission_register.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/broker_commission_register.sql:null:bbafd9ab67bb6464539381ef2165b5028baff30c:create

create table samqa.broker_commission_register (
    broker_id        number,
    broker_lic       varchar2(30 byte),
    broker_rate      number,
    entrp_id         number,
    pers_id          number,
    acc_id           number,
    pay_date         date,
    amount           number,
    reason_code      number,
    change_num       number,
    creation_date    date,
    created_by       number,
    last_update_date date,
    last_updated_by  number,
    account_type     varchar2(30 byte),
    no_of_employees  number,
    account_category varchar2(30 byte)
);

