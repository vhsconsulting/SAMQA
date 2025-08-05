-- liquibase formatted sql
-- changeset SAMQA:1754374162537 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\rate_structure.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/rate_structure.sql:null:76f7e31d7b73a0c5c5e9d7b6c536387e572daff2:create

create table samqa.rate_structure (
    rate_id          number,
    rate_code        varchar2(30 byte),
    rate_type        varchar2(30 byte),
    plan_type        varchar2(30 byte),
    rate_description varchar2(2000 byte),
    status           varchar2(30 byte) default 'A',
    effective_date   date default sysdate,
    note             varchar2(2000 byte),
    creation_date    date default sysdate,
    created_by       number,
    last_update_date date default sysdate,
    last_updated_by  number,
    plan_code        varchar2(30 byte)
);

create index samqa.rate_structure_n3 on
    samqa.rate_structure (
        rate_code,
        rate_type
    );

alter table samqa.rate_structure
    add constraint rate_structure_u1 unique ( rate_code )
        using index samqa.rate_structure_n3 enable;

alter table samqa.rate_structure add primary key ( rate_id )
    using index enable;

