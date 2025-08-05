-- liquibase formatted sql
-- changeset SAMQA:1754374164172 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\vendors.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/vendors.sql:null:66a0eaba962603d5c27c7031fb177946426ba5ce:create

create table samqa.vendors (
    vendor_id           number,
    orig_sys_vendor_ref varchar2(255 byte),
    vendor_name         varchar2(255 byte),
    address1            varchar2(2000 byte),
    address2            varchar2(2000 byte),
    city                varchar2(255 byte),
    state               varchar2(255 byte),
    zip                 varchar2(255 byte),
    expense_account     varchar2(255 byte),
    acc_num             varchar2(255 byte),
    vendor_in_peachtree varchar2(1 byte),
    creation_date       date,
    created_by          number,
    last_update_date    date,
    last_updated_by     number,
    vendor_acc_num      varchar2(255 byte),
    vendor_type         varchar2(30 byte),
    vendor_status       varchar2(30 byte),
    acc_id              number,
    vendor_tax_id       varchar2(30 byte),
    phone_number        varchar2(255 byte),
    payee_nick_name     varchar2(20 byte),
    address3            varchar2(50 byte)
);

