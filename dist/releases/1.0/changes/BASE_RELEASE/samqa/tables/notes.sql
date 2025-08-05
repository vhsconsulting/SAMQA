-- liquibase formatted sql
-- changeset SAMQA:1754374161004 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\notes.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/notes.sql:null:27cfcbcc9c4ca8cdc54a6bdbeade46f7a699e0d5:create

create table samqa.notes (
    note_id       number,
    entity_id     varchar2(255 byte),
    entity_type   varchar2(255 byte),
    description   varchar2(4000 byte),
    creation_date date,
    created_by    number,
    note_status   varchar2(255 byte),
    entered_date  date default sysdate,
    acc_id        number,
    pers_id       number,
    entrp_id      number,
    note_action   varchar2(2000 byte),
    orig_sys_ref  varchar2(100 byte)
);

alter table samqa.notes
    add constraint notes_pk primary key ( note_id )
        using index enable;

