-- liquibase formatted sql
-- changeset SAMQA:1754374160120 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\map_notification_events.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/map_notification_events.sql:null:b0c8ae915c6a3f8adacb4eb37936908ea352475e:create

create table samqa.map_notification_events (
    event_name          varchar2(30 byte),
    sms_template_name   varchar2(3200 byte),
    email_template_name varchar2(3200 byte)
);

