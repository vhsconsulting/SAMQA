-- liquibase formatted sql
-- changeset SAMQA:1754373945106 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.sms_notification_to_send_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.sms_notification_to_send_v.sql:null:385242c93a9c9c75560e0b6dfeee3eacc14f5b8c:create

grant select on samqa.sms_notification_to_send_v to rl_sam1_ro;

grant select on samqa.sms_notification_to_send_v to rl_sam_ro;

grant select on samqa.sms_notification_to_send_v to rl_sam_rw;

