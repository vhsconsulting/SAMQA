-- liquibase formatted sql
-- changeset SAMQA:1754374161535 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\online_hfsa_enroll_stage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/online_hfsa_enroll_stage.sql:null:6d6ea2f9b969740dcc36923987469f3efd3b014e:create

create table samqa.online_hfsa_enroll_stage (
    enroll_stage_id    number,
    first_name         varchar2(255 byte),
    middle_name        varchar2(255 byte),
    last_name          varchar2(255 byte),
    ssn                varchar2(255 byte),
    acc_num            varchar2(255 byte),
    action             varchar2(255 byte),
    gender             varchar2(255 byte),
    address            varchar2(255 byte),
    city               varchar2(255 byte),
    state              varchar2(255 byte),
    zip                varchar2(255 byte),
    day_phone          varchar2(255 byte),
    email_address      varchar2(100 byte),
    birth_date         varchar2(255 byte),
    division_code      varchar2(30 byte),
    plan_type          varchar2(255 byte),
    effective_date     varchar2(200 byte),
    annual_election    varchar2(255 byte),
    first_payroll_date varchar2(200 byte),
    pay_contrb         varchar2(255 byte),
    no_of_periods      varchar2(255 byte),
    pay_cycle          varchar2(255 byte),
    debit_card         varchar2(255 byte),
    covg_tier_name     varchar2(255 byte),
    termination_date   varchar2(255 byte),
    plan_code          varchar2(255 byte),
    deductible         varchar2(255 byte),
    conditional_issue  varchar2(255 byte),
    note               varchar2(3200 byte),
    ip_address         varchar2(3200 byte),
    creation_date      date,
    entrp_id           number,
    batch_number       number,
    process_status     varchar2(30 byte),
    qual_event_code    varchar2(100 byte),
    carrier_id         varchar2(30 byte),
    er_ben_plan_id     number
);

alter table samqa.online_hfsa_enroll_stage add primary key ( enroll_stage_id )
    using index enable;

