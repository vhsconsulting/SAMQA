-- liquibase formatted sql
-- changeset SAMQA:1754374151325 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\addresses.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/addresses.sql:null:8f824c09c4033f42a0e3ad07a29572acea0363be:create

create table samqa.addresses (
    address_id      number(9, 0),
    entity_type     varchar2(100 byte) not null enable,
    entity_id       number(9, 0) not null enable,
    address1        varchar2(100 byte),
    address2        varchar2(100 byte),
    city            varchar2(100 byte),
    state           varchar2(2 byte),
    zip             varchar2(10 byte),
    county          varchar2(20 byte),
    po_box          varchar2(20 byte),
    phone_no        varchar2(100 byte),
    email           varchar2(100 byte),
    creation_date   date,
    created_by      number,
    last_updated_on date,
    last_updated_by number
);

alter table samqa.addresses add primary key ( address_id )
    using index enable;

