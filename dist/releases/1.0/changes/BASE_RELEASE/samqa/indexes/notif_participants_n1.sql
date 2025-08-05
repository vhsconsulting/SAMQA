-- liquibase formatted sql
-- changeset SAMQA:1754373932332 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\notif_participants_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/notif_participants_n1.sql:null:eddffbc22813d0eb856e4856cc39a3e5c8212d21:create

create index samqa.notif_participants_n1 on
    samqa.notif_participants (
        notification_id
    );

