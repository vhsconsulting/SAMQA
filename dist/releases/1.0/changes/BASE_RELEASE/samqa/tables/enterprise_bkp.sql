-- liquibase formatted sql
-- changeset SAMQA:1754374156950 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\enterprise_bkp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/enterprise_bkp.sql:null:80ab3861dc650d065b11a8e62e1f7f39b6ccb915:create

create table samqa.enterprise_bkp (
    entrp_id          number(9, 0) not null enable,
    en_code           number(3, 0) not null enable,
    name              varchar2(100 byte) not null enable,
    entrp_code        varchar2(20 byte),
    address           varchar2(100 byte),
    city              varchar2(30 byte),
    state             varchar2(2 byte),
    zip               varchar2(10 byte),
    entrp_main        number(9, 0),
    entrp_pay         number(15, 2),
    entrp_contact     varchar2(4000 byte),
    entrp_phones      varchar2(100 byte),
    entrp_email       varchar2(100 byte),
    note              varchar2(4000 byte),
    card_allowed      number(1, 0),
    merchant_id       number,
    creation_date     date,
    created_by        number,
    last_update_date  date,
    last_updated_by   number,
    contact_phone     varchar2(50 byte),
    contact_email     varchar2(100 byte),
    entrp_fax         varchar2(30 byte),
    no_of_eligible    number,
    carrier_supported varchar2(30 byte),
    entity_type       varchar2(100 byte),
    state_of_org      varchar2(100 byte),
    cobra_id_number   number,
    dba_name          varchar2(2000 byte),
    address2          varchar2(2000 byte),
    irs_business_code varchar2(30 byte)
);

