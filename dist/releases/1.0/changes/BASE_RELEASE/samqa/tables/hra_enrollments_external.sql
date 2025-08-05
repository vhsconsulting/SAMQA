-- liquibase formatted sql
-- changeset SAMQA:1754374159327 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\hra_enrollments_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/hra_enrollments_external.sql:null:7ffd78e06effe6462c9bc41dc1dba14012810db6:create

create table samqa.hra_enrollments_external (
    first_name         varchar2(255 byte),
    middle_name        varchar2(255 byte),
    last_name          varchar2(255 byte),
    gender             varchar2(30 byte),
    address            varchar2(255 byte),
    city               varchar2(255 byte),
    state              varchar2(30 byte),
    zip                varchar2(30 byte),
    day_phone          varchar2(30 byte),
    email_address      varchar2(100 byte),
    birth_date         varchar2(30 byte),
    ssn                varchar2(30 byte),
    carrier            varchar2(255 byte),
    plan_type          varchar2(30 byte),
    deductible         varchar2(30 byte),
    division_code      varchar2(30 byte),
    coverage_tier_name varchar2(255 byte),
    effective_date     varchar2(30 byte),
    bps_hra_plan       varchar2(30 byte),
    annual_election    varchar2(30 byte),
    plan_code          varchar2(30 byte),
    start_date         varchar2(30 byte),
    account_status     varchar2(30 byte),
    setup_status       varchar2(30 byte),
    debit_card         varchar2(30 byte),
    conditional_issue  varchar2(30 byte),
    broker_number      varchar2(300 byte),
    note               varchar2(3200 byte),
    group_number       varchar2(30 byte),
    acc_num            varchar2(30 byte)
)
organization external ( type oracle_loader
    default directory enroll_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'enroll.bad'
            logfile 'enroll.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( enroll_dir : 'ENR - 3-14-2012 se.csv' )
) reject limit 0;

