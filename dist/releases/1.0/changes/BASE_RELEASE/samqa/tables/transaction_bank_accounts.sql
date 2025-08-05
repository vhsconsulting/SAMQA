-- liquibase formatted sql
-- changeset SAMQA:1754374163811 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\transaction_bank_accounts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/transaction_bank_accounts.sql:null:b34a718f74fd449e29639ba7a51de64f7b280ef3:create

create table samqa.transaction_bank_accounts (
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

