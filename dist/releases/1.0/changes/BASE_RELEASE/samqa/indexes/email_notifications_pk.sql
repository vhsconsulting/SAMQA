-- liquibase formatted sql
-- changeset SAMQA:1754373930907 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\email_notifications_pk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/email_notifications_pk.sql:null:f60a03e25bbdd1887c871dbcc900f89617c64d80:create

create index samqa.email_notifications_pk on
    samqa.email_notifications (
        notification_id
    );

