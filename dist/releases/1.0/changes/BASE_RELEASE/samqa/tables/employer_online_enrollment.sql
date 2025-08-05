-- liquibase formatted sql
-- changeset SAMQA:1754374156195 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\employer_online_enrollment.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/employer_online_enrollment.sql:null:9a0ffe5589f255736401dc5bc4545fd3e90e5e09:create

create table samqa.employer_online_enrollment (
    enrollment_id                number,
    name                         varchar2(255 byte),
    ein_number                   varchar2(255 byte),
    address                      varchar2(255 byte),
    city                         varchar2(255 byte),
    state                        varchar2(255 byte),
    zip                          varchar2(255 byte),
    contact_name                 varchar2(255 byte),
    phone                        varchar2(255 byte),
    email                        varchar2(255 byte),
    fee_plan_type                number,
    plan_code                    number,
    broker_lic                   varchar2(255 byte),
    er_contribution_frequency    number,
    ee_contribution_frequency    number,
    er_contribution_flag         number,
    ee_contribution_flag         number,
    setup_fee_paid_by            number,
    maint_fee_paid_by            number,
    management_account_user_name varchar2(255 byte),
    enrollment_account_user_name varchar2(255 byte),
    management_account_password  varchar2(255 byte),
    enrollment_account_password  varchar2(255 byte),
    password_question            varchar2(255 byte),
    password_answer              varchar2(255 byte),
    entrp_id                     number,
    acc_num                      varchar2(30 byte),
    enrollment_status            varchar2(30 byte),
    error_message                varchar2(2000 byte),
    creation_date                date default sysdate,
    created_by                   number,
    last_update_date             date default sysdate,
    last_updated_by              number,
    lang_perf                    varchar2(30 byte) default 'ENGLISH',
    peo_ein                      varchar2(30 byte),
    account_type                 varchar2(100 byte) default null,
    total_no_of_ee               number default null,
    debit_card_allowed           varchar2(10 byte) default null,
    fax_no                       varchar2(100 byte),
    batch_number                 number,
    salesrep_id                  number,
    salesrep_flag                varchar2(2 byte),
    subscribe_to_acn             varchar2(10 byte),
    peo_flag                     varchar2(2 byte),
    no_of_eligible               number,
    office_phone_number          varchar2(100 byte),
    industry_type                varchar2(2000 byte),
    salesrep_name                varchar2(200 byte)
);

alter table samqa.employer_online_enrollment add primary key ( enrollment_id )
    using index enable;

