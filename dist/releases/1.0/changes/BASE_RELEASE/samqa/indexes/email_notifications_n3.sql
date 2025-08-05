-- liquibase formatted sql
-- changeset SAMQA:1754373930897 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\email_notifications_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/email_notifications_n3.sql:null:6d687a130bc1efdba9feb1c3efe703290f402b15:create

create index samqa.email_notifications_n3 on
    samqa.email_notifications (
        mail_status
    );

