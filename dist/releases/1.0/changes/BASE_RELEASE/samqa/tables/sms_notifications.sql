-- liquibase formatted sql
-- changeset SAMQA:1754374163332 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\sms_notifications.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/sms_notifications.sql:null:705a7c0c15fc5c0eb8c5ca2ee9824d7ba573011c:create

create table samqa.sms_notifications (
    notification_id  number,
    phone_number     varchar2(30 byte),
    sms_text         varchar2(4000 byte),
    sms_status       varchar2(30 byte) default 'READY',
    event_name       varchar2(200 byte),
    acc_id           number,
    error_message    varchar2(4000 byte),
    creation_date    date default sysdate,
    created_by       number default 0,
    last_update_date date default sysdate,
    last_updated_by  number default 0
);

alter table samqa.sms_notifications add primary key ( notification_id )
    using index enable;

