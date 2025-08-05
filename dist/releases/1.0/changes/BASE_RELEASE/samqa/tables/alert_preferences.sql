-- liquibase formatted sql
-- changeset SAMQA:1754374151416 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\alert_preferences.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/alert_preferences.sql:null:8ad6f9e9c9cf9056ae73c65b9eff3e0be75becc2:create

create table samqa.alert_preferences (
    event_name         varchar2(30 byte),
    subscribe_to_sms   varchar2(1 byte),
    subscribe_to_email varchar2(1 byte),
    ssn                varchar2(20 byte),
    email              varchar2(255 byte),
    phone_number       varchar2(255 byte),
    created_by         number,
    creation_date      date
);

