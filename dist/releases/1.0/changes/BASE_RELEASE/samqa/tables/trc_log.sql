-- liquibase formatted sql
-- changeset SAMQA:1754374163825 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\trc_log.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/trc_log.sql:null:36ffc40ab0395f874d4c17d099c2777b308cae34:create

create table samqa.trc_log (
    event_id number,
    username varchar2(30 byte),
    curdate  date,
    line     varchar2(4000 byte)
);

create unique index samqa.trc_log_pk on
    samqa.trc_log (
        event_id
    );

alter table samqa.trc_log
    add constraint trc_log_pk
        primary key ( event_id )
            using index samqa.trc_log_pk enable;

