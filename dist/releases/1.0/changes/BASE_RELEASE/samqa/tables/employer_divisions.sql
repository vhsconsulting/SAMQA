-- liquibase formatted sql
-- changeset SAMQA:1754374156104 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\employer_divisions.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/employer_divisions.sql:null:9f8edc111ed2af4d25ea59b494c4533be1b68948:create

create table samqa.employer_divisions (
    division_id      number,
    division_code    varchar2(10 byte) not null enable,
    division_name    varchar2(255 byte) not null enable,
    description      varchar2(3200 byte),
    entrp_id         number,
    division_main    number,
    status           varchar2(1 byte) default 'A',
    creation_date    date default sysdate,
    created_by       number,
    last_update_date date default sysdate,
    last_updated_by  number,
    address1         varchar2(255 byte),
    address2         varchar2(2000 byte),
    city             varchar2(255 byte),
    state            varchar2(255 byte),
    zip              varchar2(255 byte),
    phone            varchar2(255 byte),
    fax              varchar2(255 byte),
    cobra_id_number  varchar2(255 byte)
);

alter table samqa.employer_divisions add primary key ( division_id )
    using index enable;

