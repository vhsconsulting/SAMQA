-- liquibase formatted sql
-- changeset SAMQA:1754374159369 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\incident_attachments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/incident_attachments.sql:null:0fde03c7e6d8a6e1741c47e917b7712d197ea55e:create

create table samqa.incident_attachments (
    attachment         blob,
    created_by         varchar2(240 byte) not null enable,
    creation_date      date not null enable,
    last_updated_by    varchar2(240 byte) not null enable,
    last_update_date   date not null enable,
    file_name          varchar2(400 byte),
    mime_type          varchar2(240 byte),
    file_attachment_id number,
    attachment_id      number not null enable,
    incident_id        number,
    history_id         number
);

