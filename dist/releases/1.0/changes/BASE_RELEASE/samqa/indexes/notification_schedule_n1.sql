-- liquibase formatted sql
-- changeset SAMQA:1754373932346 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\notification_schedule_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/notification_schedule_n1.sql:null:65073671ad910ce5ac3e7721733e13a13f0f51f4:create

create index samqa.notification_schedule_n1 on
    samqa.notification_schedule (
        notif_template_id
    );

