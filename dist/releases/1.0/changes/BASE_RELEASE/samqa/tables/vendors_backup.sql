-- liquibase formatted sql
-- changeset SAMQA:1754374164191 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\vendors_backup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/vendors_backup.sql:null:dd37e51cfea3f35e8a4d8af7c4b8fe9f2855fe44:create

create table samqa.vendors_backup (
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
    phone_number        varchar2(255 byte)
);

