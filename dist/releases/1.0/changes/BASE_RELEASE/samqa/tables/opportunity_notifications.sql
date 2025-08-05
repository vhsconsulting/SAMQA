-- liquibase formatted sql
-- changeset SAMQA:1754374161741 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\opportunity_notifications.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/opportunity_notifications.sql:null:f4c457ffab9fd252f7229e7e1822cdf56ab57801:create

create table samqa.opportunity_notifications (
    notification_id   number,
    from_address      varchar2(3200 byte),
    to_address        varchar2(3200 byte),
    cc_address        varchar2(3200 byte),
    subject           varchar2(3200 byte),
    mail_status       varchar2(30 byte),
    creation_date     date,
    created_by        number,
    last_update_date  date,
    last_updated_by   number,
    acc_id            number,
    event             varchar2(500 byte),
    batch_num         number,
    template_name     varchar2(3200 byte),
    message_body_extn varchar2(4000 byte),
    opp_id            number,
    message_body      clob
);

