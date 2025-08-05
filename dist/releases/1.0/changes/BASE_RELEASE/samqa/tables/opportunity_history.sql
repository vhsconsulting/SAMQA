-- liquibase formatted sql
-- changeset SAMQA:1754374161702 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\opportunity_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/opportunity_history.sql:null:36d8cc59c950159e4cafc9fa974bd88a1939d481:create

create table samqa.opportunity_history (
    history_id          number not null enable,
    text                varchar2(4000 byte),
    status              varchar2(240 byte),
    created_by          varchar2(240 byte),
    created_date        date,
    opp_id              number not null enable,
    note_id             number,
    text_type           varchar2(50 byte),
    notes_assigned_pers varchar2(100 byte),
    notes_assigned_dept varchar2(255 byte)
);

