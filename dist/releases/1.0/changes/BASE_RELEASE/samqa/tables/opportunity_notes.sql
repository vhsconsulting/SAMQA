-- liquibase formatted sql
-- changeset SAMQA:1754374161716 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\opportunity_notes.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/opportunity_notes.sql:null:e6b6f23ff82557f29a964ce2bd9b84c537309bb7:create

create table samqa.opportunity_notes (
    note_id           number not null enable,
    description       varchar2(4000 byte) not null enable,
    creation_date     date,
    created_by        number,
    last_updated_date date,
    last_updated_by   number,
    opp_id            number not null enable
);

alter table samqa.opportunity_notes
    add constraint opportunity_notes_pk primary key ( note_id )
        using index enable;

