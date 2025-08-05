-- liquibase formatted sql
-- changeset SAMQA:1754374151551 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\aop_downsubscr_message.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/aop_downsubscr_message.sql:null:a37cca1782977565df38ea4b2edfd541a89a612f:create

create table samqa.aop_downsubscr_message (
    id         number not null enable,
    name       varchar2(100 byte),
    language   varchar2(100 byte),
    message    varchar2(4000 byte),
    created    date not null enable,
    created_by varchar2(255 byte) not null enable,
    updated    date not null enable,
    updated_by varchar2(255 byte) not null enable
);

alter table samqa.aop_downsubscr_message
    add constraint aop_downsubscr_message_pk primary key ( id )
        using index enable;

