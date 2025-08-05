-- liquibase formatted sql
-- changeset SAMQA:1754374161682 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\opportunity_attachments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/opportunity_attachments.sql:null:5d3a21d9203665d2583c6a1a4b44bc771631a5b2:create

create table samqa.opportunity_attachments (
    created_by         varchar2(240 byte) not null enable,
    created_date       date not null enable,
    updated_by         varchar2(240 byte) not null enable,
    updated_date       date not null enable,
    file_name          varchar2(400 byte),
    file_attachment_id number not null enable,
    attachment_id      number not null enable,
    opp_id             number not null enable
);

alter table samqa.opportunity_attachments
    add constraint opportunities_attachments_pk primary key ( attachment_id )
        using index enable;

