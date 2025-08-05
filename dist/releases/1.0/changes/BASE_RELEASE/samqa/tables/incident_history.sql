-- liquibase formatted sql
-- changeset SAMQA:1754374159441 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\incident_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/incident_history.sql:null:079b047b58cf89daeabaf277b342f7ffd5532e23:create

create table samqa.incident_history (
    history_id           number,
    ticket_number        varchar2(240 byte) not null enable,
    text                 varchar2(4000 byte),
    status               varchar2(240 byte),
    created_by           varchar2(240 byte),
    created_date         date,
    notes                clob,
    note_blob            blob,
    incident_id          number not null enable,
    notes_assigned_pers  varchar2(400 byte),
    display_comment_flag varchar2(1 byte)
);

alter table samqa.incident_history
    add constraint incident_history_pk primary key ( history_id )
        using index enable;

