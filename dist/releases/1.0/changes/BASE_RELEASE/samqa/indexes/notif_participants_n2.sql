-- liquibase formatted sql
-- changeset SAMQA:1754373932339 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\notif_participants_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/notif_participants_n2.sql:null:03c37b330d02f1bc8c89514d8a695bfe0e636da5:create

create index samqa.notif_participants_n2 on
    samqa.notif_participants (
        user_id
    );

