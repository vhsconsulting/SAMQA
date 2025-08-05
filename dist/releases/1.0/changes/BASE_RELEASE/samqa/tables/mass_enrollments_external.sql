-- liquibase formatted sql
-- changeset SAMQA:1754374160362 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\mass_enrollments_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/mass_enrollments_external.sql:null:690b52af9d6550c3ecd444727d305f8e0d0cd52a:create

create table samqa.mass_enrollments_external (
    title           varchar2(20 byte),
    first_name      varchar2(255 byte),
    middle_name     varchar2(255 byte),
    last_name       varchar2(255 byte),
    gender          varchar2(30 byte),
    address         varchar2(255 byte),
    city            varchar2(255 byte),
    state           varchar2(30 byte),
    zip             varchar2(30 byte),
    day_phone       varchar2(30 byte),
    email_address   varchar2(100 byte),
    birth_date      varchar2(30 byte),
    ssn             varchar2(30 byte),
    driver_license  varchar2(30 byte),
    passport        varchar2(30 byte),
    carrier         varchar2(255 byte),
    plan_type       varchar2(30 byte),
    deductible      varchar2(30 byte),
    effective_date  varchar2(30 byte),
    plan_code       varchar2(30 byte),
    start_date      varchar2(30 byte),
    check_number    varchar2(255 byte),
    check_amount    number,
    employer_amount number,
    employee_amount number,
    account_status  varchar2(30 byte),
    setup_status    varchar2(30 byte),
    debit_card      varchar2(30 byte),
    employer_name   varchar2(300 byte),
    broker_number   varchar2(300 byte),
    note            varchar2(3200 byte),
    sign_on_file    varchar2(30 byte),
    group_number    varchar2(30 byte),
    division_code   varchar2(30 byte)
)
organization external ( type oracle_loader
    default directory enroll_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'Sterling_LSA_Eligibility_Template - Navien LSA 2025 07.01.25.csv.bad'
            logfile 'Sterling_LSA_Eligibility_Template - Navien LSA 2025 07.01.25.csv.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( enroll_dir : 'Sterling_LSA_Eligibility_Template - Navien LSA 2025 07.01.25.csv' )
) reject limit 0;

