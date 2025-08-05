-- liquibase formatted sql
-- changeset SAMQA:1754374157760 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\er_add_remitt_bank_notification.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/er_add_remitt_bank_notification.sql:null:9b92dee3b0ff1c262c303365faba1e2dac95e91f:create

create table samqa.er_add_remitt_bank_notification (
    er_remitt_bank_notif_id number not null enable,
    acc_id                  number,
    entity_id               number,
    entity_type             varchar2(255 byte),
    process_status          varchar2(1 byte),
    notification_id         number,
    creation_date           date,
    created_by              number,
    mailed_date             date
);

