-- liquibase formatted sql
-- changeset SAMQA:1754373930888 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\email_notifications_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/email_notifications_n1.sql:null:05240635307ab735e295bf9483997beeb81b108c:create

create index samqa.email_notifications_n1 on
    samqa.email_notifications (
        event
    );

