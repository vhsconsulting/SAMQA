-- liquibase formatted sql
-- changeset SAMQA:1754374162309 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\plan_employer_contacts_stage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/plan_employer_contacts_stage.sql:null:b0733e7d262a794f59fa2dd8572c000a0f2a851e:create

create table samqa.plan_employer_contacts_stage (
    plan_admin_name          varchar2(100 byte),
    contact_type             varchar2(100 byte),
    contact_name             varchar2(100 byte),
    phone_num                varchar2(100 byte),
    email                    varchar2(100 byte),
    address1                 varchar2(1000 byte),
    address2                 varchar2(1000 byte),
    city                     varchar2(100 byte),
    state                    varchar2(100 byte),
    zip_code                 varchar2(100 byte),
    plan_agent               varchar2(100 byte),
    description              varchar2(100 byte),
    agent_name               varchar2(100 byte),
    legal_agent_contact      varchar2(100 byte),
    legal_agent_phone        varchar2(100 byte),
    legal_agent_email        varchar2(100 byte),
    trust_fund               varchar2(2 byte),
    created_by               number,
    creation_date            date,
    last_updated_by          number,
    last_update_date         date,
    record_id                number,
    entity_id                number,
    batch_number             number,
    admin_type               varchar2(100 byte),
    trustee_name             varchar2(100 byte),
    trustee_contact_type     varchar2(100 byte),
    trustee_contact_name     varchar2(100 byte),
    trustee_contact_phone    varchar2(100 byte),
    trustee_contact_email    varchar2(100 byte),
    legal_agent_contact_type varchar2(100 byte),
    governing_state          varchar2(2 byte)
);

