-- liquibase formatted sql
-- changeset SAMQA:1754374163864 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\user_bank_acct_backup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/user_bank_acct_backup.sql:null:d89facaaa87b98cee1147e727a8bcd849be93a56:create

create table samqa.user_bank_acct_backup (
    bank_acct_id       number not null enable,
    acc_id             number not null enable,
    display_name       varchar2(255 byte),
    bank_acct_type     varchar2(2 byte) not null enable,
    bank_routing_num   varchar2(9 byte) not null enable,
    bank_acct_num      varchar2(20 byte) not null enable,
    bank_name          varchar2(255 byte) not null enable,
    last_updated_by    number,
    created_by         number,
    last_update_date   date,
    creation_date      date,
    status             varchar2(1 byte),
    bank_account_usage varchar2(30 byte),
    authorized_by      varchar2(50 byte),
    note               varchar2(255 byte),
    inactive_reason    varchar2(30 byte),
    inactive_date      date,
    bank_acct_code     varchar2(30 byte)
);

