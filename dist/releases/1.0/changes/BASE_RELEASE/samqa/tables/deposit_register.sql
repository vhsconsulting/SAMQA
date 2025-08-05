-- liquibase formatted sql
-- changeset SAMQA:1754374155708 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\deposit_register.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/deposit_register.sql:null:a011e11351292d03ddd0364971ae3828a66cfb7d:create

create table samqa.deposit_register (
    deposit_register_id number,
    first_name          varchar2(2000 byte),
    last_name           varchar2(2000 byte),
    acc_num             varchar2(30 byte),
    acc_id              number,
    entrp_id            number,
    check_number        varchar2(255 byte),
    check_amount        number,
    trans_date          varchar2(30 byte),
    new_app_flag        varchar2(1 byte),
    new_app_amount      number,
    status              varchar2(30 byte),
    note                varchar2(3200 byte),
    creation_date       date,
    created_by          number,
    last_update_date    date,
    last_updated_by     number,
    posted_flag         varchar2(1 byte),
    reconciled_flag     varchar2(1 byte),
    list_bill           number,
    orig_sys_ref        number,
    ssn                 varchar2(15 byte),
    duplicate_flag      varchar2(1 byte) default 'N'
);

