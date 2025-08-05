-- liquibase formatted sql
-- changeset SAMQA:1754374154106 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\contact_import.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/contact_import.sql:null:936584e55d62329cea0b3c65d0c184ab697cb38a:create

create table samqa.contact_import (
    name          varchar2(2000 byte),
    contact_email varchar2(2000 byte),
    acc_num       varchar2(100 byte),
    entrp_id      number,
    tax_id        varchar2(30 byte)
);

