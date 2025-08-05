-- liquibase formatted sql
-- changeset SAMQA:1754374156699 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\enroll_main_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/enroll_main_external.sql:null:2e43a106ebcf3f6efe9c0335090c20ed09d52021:create

create table samqa.enroll_main_external (
    username           varchar2(200 byte),
    acct_id            varchar2(100 byte),
    acct_type          varchar2(100 byte),
    salutation         varchar2(300 byte),
    first_name         varchar2(200 byte),
    middle_name        varchar2(100 byte),
    last_name          varchar2(500 byte),
    emp_group          varchar2(100 byte),
    emp_name           varchar2(100 byte),
    emp_contact_person varchar2(100 byte),
    gender             varchar2(100 byte),
    ssn                varchar2(200 byte),
    dob                varchar2(100 byte),
    drivers_lic        varchar2(200 byte),
    passport           varchar2(200 byte),
    address_1          varchar2(100 byte),
    address_2          varchar2(100 byte),
    city               varchar2(200 byte),
    county             varchar2(200 byte),
    state              varchar2(200 byte),
    zip_code           varchar2(100 byte),
    day_phone          varchar2(200 byte),
    eve_phone          varchar2(200 byte),
    email              varchar2(500 byte),
    contact_method     varchar2(100 byte),
    broker_designation number,
    carrier_name       varchar2(100 byte),
    carrier_id         varchar2(100 byte),
    subscriber_id      varchar2(200 byte),
    plan_eff_date      varchar2(100 byte),
    hdhp_option        number,
    annual_ded         varchar2(100 byte),
    plan_code          varchar2(100 byte),
    hsa_plan_type      varchar2(100 byte),
    setup_fee          varchar2(100 byte),
    init_maint_fee     varchar2(100 byte),
    initial_contrib    varchar2(100 byte),
    bank_name          varchar2(100 byte),
    bank_acct_type     varchar2(100 byte),
    bank_routing_num   varchar2(100 byte),
    bank_acct_num      varchar2(100 byte),
    date_created       varchar2(100 byte),
    ip_address         varchar2(20 byte),
    referrer           varchar2(150 byte),
    processed_koa      varchar2(100 byte),
    debit_card_flg     varchar2(100 byte),
    subscriber_status  varchar2(1 byte)
)
organization external ( type oracle_loader
    default directory online_enroll_dir access parameters (
        records delimited by newline
        fields terminated by '~' optionally enclosed by '"' missing field values are null
    ) location ( 'Online_Enroll_Main.csv' )
) reject limit 0;

