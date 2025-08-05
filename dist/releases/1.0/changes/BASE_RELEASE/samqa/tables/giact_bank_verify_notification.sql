-- liquibase formatted sql
-- changeset SAMQA:1754374158971 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\giact_bank_verify_notification.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/giact_bank_verify_notification.sql:null:83977dc2922c81a509ce4800e162068f4bca02d0:create

create table samqa.giact_bank_verify_notification (
    bank_notif_id      number not null enable,
    bank_acct_id       number,
    age_of_bank_notify number,
    notification_type  varchar2(255 byte),
    mailed_date        date,
    mailed_to          varchar2(2000 byte),
    creation_date      date,
    notification_id    number,
    email_sent_to      varchar2(4000 byte),
    template_name      varchar2(100 byte)
);

