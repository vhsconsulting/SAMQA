-- liquibase formatted sql
-- changeset SAMQA:1754373932354 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\notification_schedule_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/notification_schedule_n2.sql:null:d767969eafea705a487033dc047d28bd62e14469:create

create index samqa.notification_schedule_n2 on
    samqa.notification_schedule (
        entrp_id
    );

