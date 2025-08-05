-- liquibase formatted sql
-- changeset SAMQA:1754374160002 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\letters.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/letters.sql:null:aeda50decda805eae2b5485cbca9b29baa3667a8:create

create table samqa.letters (
    pers_id   number(9, 0) not null enable,
    send_date date not null enable,
    about     varchar2(100 byte) not null enable,
    note      varchar2(4000 byte)
);

create unique index samqa.letters_pk on
    samqa.letters (
        pers_id,
        send_date
    );

alter table samqa.letters
    add constraint letters_pk
        primary key ( pers_id,
                      send_date )
            using index samqa.letters_pk enable;

