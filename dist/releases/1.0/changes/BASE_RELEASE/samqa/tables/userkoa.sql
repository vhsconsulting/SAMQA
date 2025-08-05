-- liquibase formatted sql
-- changeset SAMQA:1754374164069 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\userkoa.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/userkoa.sql:null:83dd26328eb2ef0a34e89d3cbe7cc9220299f34b:create

create table samqa.userkoa (
    uname     varchar2(30 byte),
    pwd       varchar2(30 byte),
    pers_name varchar2(30 byte) not null enable,
    pers_id   number(9, 0),
    note      varchar2(4000 byte)
);

create unique index samqa.userkoa_u1 on
    samqa.userkoa (
        pers_name
    );

create unique index samqa.userkoa_pk on
    samqa.userkoa (
        uname
    );

alter table samqa.userkoa
    add constraint userkoa_pk
        primary key ( uname )
            using index samqa.userkoa_pk enable;

alter table samqa.userkoa
    add constraint userkoa_u1 unique ( pers_name )
        using index samqa.userkoa_u1 enable;

