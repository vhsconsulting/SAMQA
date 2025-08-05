-- liquibase formatted sql
-- changeset SAMQA:1754374161049 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\notification_schedule.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/notification_schedule.sql:null:cb3622391d30949fb9bbde6a853e6b1db0e5ea4a:create

create table samqa.notification_schedule (
    notif_schedule_id   number,
    notification_entity varchar2(100 byte),
    notif_template_id   number,
    entrp_id            number,
    product_type        varchar2(255 byte),
    description         varchar2(1000 byte),
    send_notification   varchar2(1 byte),
    trigger_table       varchar2(255 byte),
    trigger_column      varchar2(1000 byte),
    trigger_condition   varchar2(1000 byte),
    trigger_on          number,
    creation_date       date,
    created_by          number,
    schedule_name       varchar2(100 byte)
);

alter table samqa.notification_schedule add primary key ( notif_schedule_id )
    using index enable;

