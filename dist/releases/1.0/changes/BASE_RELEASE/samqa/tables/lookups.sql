-- liquibase formatted sql
-- changeset SAMQA:1754374160097 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\lookups.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/lookups.sql:null:b295875f15a824935f1173c2aa9daf7bcdfd8f9e:create

create table samqa.lookups (
    lookup_code       varchar2(30 byte),
    lookup_name       varchar2(300 byte),
    description       varchar2(1000 byte),
    creation_date     date,
    last_updated_date date,
    meaning           varchar2(255 byte),
    seq_num           number,
    status            varchar2(1 byte)
);

create unique index samqa.lookups_u1 on
    samqa.lookups (
        lookup_name,
        lookup_code
    );

alter table samqa.lookups
    add constraint lookups_pk
        primary key ( lookup_code,
                      lookup_name )
            using index samqa.lookups_u1 enable;

