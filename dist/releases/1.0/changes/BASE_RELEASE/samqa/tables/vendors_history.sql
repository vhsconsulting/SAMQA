-- liquibase formatted sql
-- changeset SAMQA:1754374164207 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\vendors_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/vendors_history.sql:null:b059f961e861ac87b75156d6c30231c45002b66a:create

create table samqa.vendors_history (
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
    last_updated_by     number
);

