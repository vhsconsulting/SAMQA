-- liquibase formatted sql
-- changeset SAMQA:1754374161022 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\notes_bkp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/notes_bkp.sql:null:f0116e70fd0182238304edc5db7b0013ad94808a:create

create table samqa.notes_bkp (
    note_id       number,
    entity_id     varchar2(255 byte),
    entity_type   varchar2(255 byte),
    description   varchar2(4000 byte),
    creation_date date,
    created_by    number,
    note_status   varchar2(255 byte)
);

