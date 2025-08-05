-- liquibase formatted sql
-- changeset SAMQA:1754374158334 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\external_vendor_credentials.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/external_vendor_credentials.sql:null:27546cee888355139a54d5b48995d5c41d4b8db8:create

create table samqa.external_vendor_credentials (
    vendor_id    number,
    vendor_name  varchar2(255 byte),
    user_name    varchar2(255 byte),
    password     varchar2(255 byte),
    public_key   varchar2(3200 byte),
    private_key  varchar2(3200 byte),
    vendor_email varchar2(3200 byte)
);

