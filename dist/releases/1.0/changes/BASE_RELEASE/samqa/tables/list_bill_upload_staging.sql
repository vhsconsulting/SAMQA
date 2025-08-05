-- liquibase formatted sql
-- changeset SAMQA:1754374160034 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\list_bill_upload_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/list_bill_upload_staging.sql:null:4d75626a47f3fa47ee03b53a892d89af953aadad:create

create table samqa.list_bill_upload_staging (
    first_name          varchar2(100 byte),
    last_name           varchar2(100 byte),
    er_contrb           varchar2(100 byte),
    ee_contrb           varchar2(100 byte),
    er_fee_contrb       varchar2(100 byte),
    ee_fee_contrb       varchar2(100 byte),
    reason_code         varchar2(100 byte),
    note                varchar2(100 byte),
    list_bill_num       varchar2(100 byte),
    acct_num            varchar2(100 byte),
    fee_date            varchar2(100 byte),
    plan_type           varchar2(100 byte),
    type_of_contrb      varchar2(100 byte),
    error_message       varchar2(2000 byte),
    process_status      varchar2(20 byte),
    batch_number        number,
    creation_date       date,
    created_by          varchar2(30 byte),
    last_update_date    date,
    last_updated_by     varchar2(30 byte),
    list_bill_upload_id number
);

alter table samqa.list_bill_upload_staging add primary key ( list_bill_upload_id )
    using index enable;

