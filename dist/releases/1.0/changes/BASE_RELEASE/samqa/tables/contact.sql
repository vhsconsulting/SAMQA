-- liquibase formatted sql
-- changeset SAMQA:1754374154083 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\contact.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/contact.sql:null:3eb21748681bbde2f6b9afa6069647beee7117f0:create

create table samqa.contact (
    contact_id         number,
    entity_id          varchar2(255 byte),
    entity_type        varchar2(255 byte),
    title              varchar2(255 byte),
    first_name         varchar2(255 byte),
    last_name          varchar2(255 byte),
    middle_name        varchar2(255 byte),
    gender             varchar2(255 byte),
    status             varchar2(3 byte),
    start_date         date,
    end_date           date,
    phone              varchar2(255 byte),
    email              varchar2(255 byte),
    fax                varchar2(255 byte),
    note               varchar2(2000 byte),
    user_id            number,
    creation_date      date default sysdate,
    created_by         number,
    last_update_date   date default sysdate,
    last_updated_by    number,
    account_type       varchar2(255 byte),
    cobra_id_number    varchar2(255 byte),
    contact_type       varchar2(30 byte),
    can_contact        varchar2(1 byte) default 'Y',
    division_code      varchar2(30 byte),
    cobra_email        varchar2(1 byte) default 'N',
    cobra_contact_type varchar2(500 byte)
);

alter table samqa.contact add primary key ( contact_id )
    using index enable;

