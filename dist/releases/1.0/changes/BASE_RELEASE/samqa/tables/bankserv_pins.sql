-- liquibase formatted sql
-- changeset SAMQA:1754374151987 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\bankserv_pins.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/bankserv_pins.sql:null:094a75410a8b12dea24766e362c1c81fc580fd56:create

create table samqa.bankserv_pins (
    bank_name        varchar2(255 byte),
    routing_number   varchar2(255 byte),
    account_number   varchar2(255 byte),
    description      varchar2(255 byte),
    bankserv_pin     varchar2(255 byte),
    creation_date    date,
    effective_date   date,
    account_type     varchar2(30 byte),
    status           varchar2(1 byte),
    transaction_type varchar2(30 byte)
);

