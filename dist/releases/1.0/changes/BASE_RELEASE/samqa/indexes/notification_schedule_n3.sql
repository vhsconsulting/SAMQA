-- liquibase formatted sql
-- changeset SAMQA:1754373932362 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\notification_schedule_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/notification_schedule_n3.sql:null:ea41052d05fd904d34fa8f77ade08a37dd98effd:create

create index samqa.notification_schedule_n3 on
    samqa.notification_schedule (
        schedule_name
    );

