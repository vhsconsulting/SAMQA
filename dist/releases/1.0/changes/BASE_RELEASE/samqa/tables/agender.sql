-- liquibase formatted sql
-- changeset SAMQA:1754374151356 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\agender.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/agender.sql:null:a97ff5edee914924162e93e11c04367a4e265081:create

create table samqa.agender (
    low number(3, 0),
    hi  number(5, 0),
    age varchar2(20 byte)
);

create unique index samqa.agender_pk on
    samqa.agender (
        low
    );

alter table samqa.agender
    add constraint agender_pk
        primary key ( low )
            using index samqa.agender_pk enable;

