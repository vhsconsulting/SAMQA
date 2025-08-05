-- liquibase formatted sql
-- changeset SAMQA:1754374155871 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\email_notifications.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/email_notifications.sql:null:9c2eaee55579cd7614581a200990cd7c479467dd:create

create table samqa.email_notifications (
    notification_id  number,
    from_address     varchar2(3200 byte),
    to_address       varchar2(3200 byte),
    cc_address       varchar2(3200 byte),
    subject          varchar2(3200 byte),
    message_body     varchar2(4000 byte),
    mail_status      varchar2(30 byte),
    creation_date    date,
    created_by       number,
    last_update_date date,
    last_updated_by  number,
    acc_id           number,
    event            varchar2(500 byte),
    batch_num        number,
    template_name    varchar2(3200 byte),
    attachment_id    number
);

