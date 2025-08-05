-- liquibase formatted sql
-- changeset SAMQA:1754374159418 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\incident_details.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/incident_details.sql:null:34189220302554a2c29bac83231c0c1a45adfb98:create

create table samqa.incident_details (
    incident_id         number,
    ticket_number       varchar2(240 byte),
    priority            varchar2(240 byte),
    account_name        varchar2(400 byte),
    subject             varchar2(4000 byte),
    description         clob,
    assigned_to         varchar2(400 byte),
    created_by          varchar2(30 byte),
    creation_date       timestamp(6),
    last_updated_by     varchar2(30 byte),
    last_update_date    timestamp(6),
    identifier          varchar2(400 byte),
    reporting_person    varchar2(400 byte),
    status              varchar2(20 byte),
    email               varchar2(240 byte),
    watch_list          varchar2(4000 byte),
    assigned_pers       varchar2(100 byte),
    document_purpose    varchar2(100 byte),
    email_pref          varchar2(1 byte),
    ticket_type         varchar2(20 byte),
    external_display    varchar2(3 byte),
    product_type        varchar2(240 byte),
    entity_id           number,
    entity_type         varchar2(30 byte),
    external_identifier varchar2(50 byte),
    resolution          varchar2(4000 byte),
    created_by_phone    varchar2(2 byte) default 'N',
    ext_sub_identifier  varchar2(200 byte),
    type_of_issue       varchar2(50 byte)
);

alter table samqa.incident_details
    add constraint incident_details_pk primary key ( incident_id )
        using index enable;

