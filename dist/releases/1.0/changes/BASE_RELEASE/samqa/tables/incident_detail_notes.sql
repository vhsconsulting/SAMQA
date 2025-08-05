-- liquibase formatted sql
-- changeset SAMQA:1754374159384 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\incident_detail_notes.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/incident_detail_notes.sql:null:c8e7ebae2d2fd833a95718f69abbd97075252091:create

create table samqa.incident_detail_notes (
    incident_id       number,
    ticket_number     varchar2(240 byte),
    notes             clob,
    created_by        varchar2(240 byte),
    creation_date     date,
    last_updated_by   varchar2(240 byte),
    last_updated_date date,
    documents         blob,
    file_name         varchar2(400 byte),
    mime_type         varchar2(400 byte)
);

alter table samqa.incident_detail_notes
    add constraint incident_detail_notes_pk primary key ( incident_id )
        using index enable;

