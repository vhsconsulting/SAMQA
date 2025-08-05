-- liquibase formatted sql
-- changeset SAMQA:1754374151717 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ar_invoice_notifications.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ar_invoice_notifications.sql:null:6b637322969c657e44c6a14607db060f9f93d7fd:create

create table samqa.ar_invoice_notifications (
    invoice_notif_id  number,
    invoice_id        number,
    age_of_invoice    number,
    notification_type varchar2(255 byte),
    mailed_date       date,
    mailed_to         varchar2(2000 byte),
    creation_date     date,
    notification_id   number,
    email_sent_to     varchar2(4000 byte),
    template_name     varchar2(100 byte)
);

alter table samqa.ar_invoice_notifications add primary key ( invoice_notif_id )
    using index enable;

