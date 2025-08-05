-- liquibase formatted sql
-- changeset SAMQA:1754373931445 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\event_notifications_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/event_notifications_n1.sql:null:27f44202d5b4c5a63cf217c6c7c7d66395791d70:create

create index samqa.event_notifications_n1 on
    samqa.event_notifications (
        event_type,
        template_name
    );

