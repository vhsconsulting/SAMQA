-- liquibase formatted sql
-- changeset SAMQA:1754374158225 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\event_notifications.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/event_notifications.sql:null:a0316e4851be57b73df509552880eb34cc455b31:create

create table samqa.event_notifications (
    event_id          number,
    event_name        varchar2(255 byte),
    event_description varchar2(255 byte),
    event_type        varchar2(255 byte),
    entity_id         varchar2(30 byte),
    acc_id            number,
    acc_num           varchar2(30 byte),
    pers_id           number,
    email             varchar2(255 byte),
    entity_type       varchar2(255 byte),
    template_name     varchar2(255 byte),
    processed_flag    varchar2(30 byte) default 'N',
    creation_date     date default sysdate,
    created_by        number,
    last_update_date  date default sysdate,
    last_updated_by   number,
    phone_number      varchar2(30 byte),
    error_message     varchar2(4000 byte)
);

alter table samqa.event_notifications add primary key ( event_id )
    using index enable;

