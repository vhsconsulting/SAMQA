-- liquibase formatted sql
-- changeset SAMQA:1754374161034 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\notif_participants.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/notif_participants.sql:null:928c0462218bd169f7efc8800efff55552d6ff81:create

create table samqa.notif_participants (
    user_id            number,
    notification_id    number,
    status             varchar2(30 byte),
    status_change_date date,
    creation_date      date,
    created_by         number,
    last_update_date   date,
    last_updated_by    number
);

