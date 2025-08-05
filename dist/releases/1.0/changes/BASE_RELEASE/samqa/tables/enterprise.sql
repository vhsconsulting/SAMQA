-- liquibase formatted sql
-- changeset SAMQA:1754374156896 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\enterprise.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/enterprise.sql:null:d29f77797e611808c7215b436a3f2e2d449a5375:create

create table samqa.enterprise (
    entrp_id             number(9, 0) not null enable,
    en_code              number(3, 0) not null enable,
    name                 varchar2(100 byte) not null enable,
    entrp_code           varchar2(20 byte),
    address              varchar2(100 byte),
    city                 varchar2(30 byte),
    state                varchar2(2 byte) default 'CA',
    zip                  varchar2(10 byte),
    entrp_main           number(9, 0),
    entrp_pay            number(15, 2),
    entrp_contact        varchar2(4000 byte),
    entrp_phones         varchar2(100 byte),
    entrp_email          varchar2(100 byte),
    note                 varchar2(4000 byte),
    card_allowed         number(1, 0) default 0,
    merchant_id          number,
    creation_date        date default sysdate,
    created_by           number,
    last_update_date     date default sysdate,
    last_updated_by      number,
    contact_phone        varchar2(50 byte),
    contact_email        varchar2(100 byte),
    entrp_fax            varchar2(30 byte),
    no_of_eligible       number default 0,
    carrier_supported    varchar2(30 byte),
    entity_type          varchar2(100 byte),
    state_of_org         varchar2(100 byte),
    cobra_id_number      number,
    dba_name             varchar2(2000 byte),
    address2             varchar2(2000 byte),
    irs_business_code    varchar2(30 byte),
    no_of_ees            number,
    office_phone_number  varchar2(100 byte),
    industry_type        varchar2(2000 byte),
    entity_name_desc     varchar2(100 byte),
    company_tax          varchar2(1 byte),
    affliated_flag       varchar2(1 byte),
    entity_type_other    varchar2(100 byte),
    state_main_office    varchar2(100 byte),
    state_govern_law     varchar2(100 byte),
    affliated_diff_ein   varchar2(100 byte),
    open_enrollment_flag varchar2(1 byte)
);

create unique index samqa.entrp_pk on
    samqa.enterprise (
        entrp_id
    );

alter table samqa.enterprise
    add constraint enterprise_card
        check ( card_allowed in ( 0, 1 ) ) enable;

alter table samqa.enterprise
    add constraint entrp_pk
        primary key ( entrp_id )
            using index samqa.entrp_pk enable;

