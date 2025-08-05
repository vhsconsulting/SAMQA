-- liquibase formatted sql
-- changeset SAMQA:1754374158662 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\files.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/files.sql:null:b7db7658c612f3a8f2743c122aa703b72511b348:create

create table samqa.files (
    file_id      number(10, 0) not null enable,
    name         varchar2(256 byte) not null enable,
    table_name   varchar2(30 byte),
    table_id     number(10, 0),
    mime_type    varchar2(128 byte),
    doc_size     number,
    dad_charset  varchar2(128 byte),
    last_updated date,
    content_type varchar2(128 byte),
    blob_content blob,
    description  varchar2(128 byte)
);

create unique index samqa.f_uk on
    samqa.files (
        name,
        table_name,
        table_id
    );

create unique index samqa.f_pk on
    samqa.files (
        file_id
    );

alter table samqa.files
    add constraint f_pk
        primary key ( file_id )
            using index samqa.f_pk enable;

alter table samqa.files
    add constraint f_uk
        unique ( name,
                 table_name,
                 table_id )
            using index samqa.f_uk enable;

