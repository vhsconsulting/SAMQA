-- liquibase formatted sql
-- changeset SAMQA:1754374158252 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\events.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/events.sql:null:94dd0c33670eb2b6624b2d0f931f204a0bfd9b0b:create

create table samqa.events (
    event_id         number,
    title            varchar2(255 byte) not null enable,
    venue            varchar2(255 byte) default null,
    event_date       date default null,
    event_time       varchar2(255 byte) default null,
    created_by       number default - 1,
    creation_date    date default sysdate,
    last_updated_by  number default - 1,
    last_update_date date default sysdate,
    description      varchar2(3200 byte),
    event_date_time  date
);

alter table samqa.events add primary key ( event_id )
    using index enable;

