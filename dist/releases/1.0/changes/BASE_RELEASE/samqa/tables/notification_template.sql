-- liquibase formatted sql
-- changeset SAMQA:1754374161073 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\notification_template.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/notification_template.sql:null:aa0f32defc6560d099b036a49623cc8fee2c40e4:create

create table samqa.notification_template (
    notif_template_id number,
    template_name     varchar2(3200 byte),
    template_subject  varchar2(3200 byte),
    template_body     varchar2(4000 byte),
    event             varchar2(255 byte),
    notification_type varchar2(255 byte),
    status            varchar2(30 byte),
    to_address        varchar2(3200 byte),
    cc_address        varchar2(3200 byte),
    creation_date     date,
    created_by        number,
    last_update_date  date,
    last_updated_by   number,
    template_type     varchar2(30 byte) default 'EMAIL'
);

