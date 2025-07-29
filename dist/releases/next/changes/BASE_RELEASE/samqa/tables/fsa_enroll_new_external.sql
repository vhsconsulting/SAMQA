-- liquibase formatted sql
-- changeset SAMQA:1753779769936 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\fsa_enroll_new_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/fsa_enroll_new_external.sql:null:5ae747c5665037391f738f556c003352c2c6a5ee:create

create table samqa.fsa_enroll_new_external (
    tpa_id              varchar2(255 byte),
    first_name          varchar2(255 byte),
    middle_name         varchar2(255 byte),
    last_name           varchar2(255 byte),
    ssn                 varchar2(255 byte),
    acct_number         varchar2(255 byte),
    action              varchar2(255 byte),
    gender              varchar2(255 byte),
    address             varchar2(255 byte),
    city                varchar2(255 byte),
    state               varchar2(255 byte),
    zip                 varchar2(255 byte),
    day_phone           varchar2(255 byte),
    email_address       varchar2(100 byte),
    birth_date          varchar2(255 byte),
    division_code       varchar2(30 byte),
    plan_type           varchar2(255 byte),
    effective_date      varchar2(200 byte),
    annual_election     varchar2(255 byte),
    first_payroll_date  varchar2(200 byte),
    pay_contrb          varchar2(255 byte),
    no_of_periods       varchar2(255 byte),
    pay_cycle           varchar2(255 byte),
    debit_card          varchar2(255 byte),
    covg_tier_name      varchar2(255 byte),
    termination_date    varchar2(255 byte),
    plan_code           varchar2(255 byte),
    group_number        varchar2(255 byte),
    orig_sys_vendor_ref varchar2(255 byte),
    deductible          varchar2(255 byte),
    conditional_issue   varchar2(255 byte),
    broker_number       varchar2(300 byte),
    note                varchar2(3200 byte)
)
organization external ( type oracle_loader
    default directory enroll_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'Main_Enrollment_FSA_HRA_SAM_temp.csv.bad'
            logfile 'Main_Enrollment_FSA_HRA_SAM_temp.csv.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( enroll_dir : 'Main_Enrollment_FSA_HRA_SAM_temp.csv' )
) reject limit 0;

