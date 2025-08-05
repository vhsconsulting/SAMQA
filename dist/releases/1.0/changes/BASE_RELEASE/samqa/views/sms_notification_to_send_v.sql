-- liquibase formatted sql
-- changeset SAMQA:1754374178713 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\sms_notification_to_send_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/sms_notification_to_send_v.sql:null:4f82a56ab75cdd73100cfdf6ce194d50188ce830:create

create or replace force editionable view samqa.sms_notification_to_send_v (
    notification_id,
    sms_text,
    sms_status
) as
    select
        s.notification_id,
        s.sms_text,
        s.sms_status
    from
        sms_notifications  s,
        user_security_info ui
    where
            strip_bad(s.phone_number) = strip_bad(ui.verified_phone_number)
        and upper(ui.verified_phone_type) = 'MOBILE'
        and s.sms_status = 'READY';

