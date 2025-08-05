-- liquibase formatted sql
-- changeset SAMQA:1754374157659 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\eob_header.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/eob_header.sql:null:a9674318d761178ad14f7fb64b4d8ae94489aeed:create

create table samqa.eob_header (
    eob_id             varchar2(255 byte),
    user_id            number,
    claim_number       varchar2(255 byte),
    provider_id        number,
    description        varchar2(3200 byte),
    service_date_from  date,
    service_date_to    date,
    service_amount     number,
    amount_due         number,
    eob_status         varchar2(255 byte),
    eob_status_code    varchar2(255 byte),
    modified           varchar2(255 byte),
    claim_id           number,
    acc_id             number,
    source             varchar2(255 byte),
    creation_date      date,
    last_update_date   date,
    last_updated_by    number,
    created_by         number,
    action             varchar2(20 byte),
    provider_name      varchar2(255 byte),
    insplan_id         number,
    company_id         number,
    notes              varchar2(4000 byte),
    member_id          varchar2(100 byte),
    patient_first_name varchar2(100 byte),
    patient_last_name  varchar2(100 byte),
    ssn                varchar2(30 byte)
);

alter table samqa.eob_header add primary key ( eob_id )
    using index enable;

