-- liquibase formatted sql
-- changeset SAMQA:1754374160924 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\nacha_data.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/nacha_data.sql:null:83dd677bda3e67ff918ab10f7f4f41848dd97ba5:create

create table samqa.nacha_data (
    record_num       varchar2(20 byte),
    destination      varchar2(30 byte),
    origin           varchar2(30 byte),
    dest_bank        varchar2(30 byte),
    company_name     varchar2(30 byte),
    data             varchar2(30 byte),
    data1            varchar2(30 byte),
    taxid            varchar2(30 byte),
    transaction_type varchar2(30 byte),
    service_class    varchar2(30 byte),
    standard_entry   varchar2(30 byte),
    batch_number     number,
    account_type     varchar2(10 byte),
    active_flag      varchar2(2 byte),
    last_updated_by  number,
    created_by       number,
    last_update_date date,
    creation_date    date
);

