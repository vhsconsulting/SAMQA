-- liquibase formatted sql
-- changeset SAMQA:1754373932369 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\notification_template_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/notification_template_u1.sql:null:142b32e0bc97abbdd0e03a47434780091df0dd37:create

create index samqa.notification_template_u1 on
    samqa.notification_template (
        template_name
    );

