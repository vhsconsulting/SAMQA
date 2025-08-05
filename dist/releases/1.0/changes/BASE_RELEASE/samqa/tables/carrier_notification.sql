-- liquibase formatted sql
-- changeset SAMQA:1754374152905 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\carrier_notification.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/carrier_notification.sql:null:8186780e85cb30a36580330e4a0a04a2d8a2fe59:create

create table samqa.carrier_notification (
    entrp_id              number,
    entity_id             number,
    entity_type           varchar2(100 byte),
    plan_number           varchar2(100 byte),
    policy_number         varchar2(100 byte),
    cariier_name          varchar2(100 byte),
    carrier_contact_name  varchar2(100 byte),
    carrier_contact_email varchar2(100 byte),
    carrier_phone_no      varchar2(100 byte),
    carrier_addr          varchar2(1000 byte),
    creation_date         date,
    created_by            number,
    last_update_date      date,
    last_updated_by       number
);

