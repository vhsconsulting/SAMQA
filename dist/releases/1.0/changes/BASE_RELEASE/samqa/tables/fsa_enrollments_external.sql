-- liquibase formatted sql
-- changeset SAMQA:1754374158840 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\fsa_enrollments_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/fsa_enrollments_external.sql:null:b5a7bf647599b561ef068a765117dd2f47cb30e1:create

create table samqa.fsa_enrollments_external (
    first_name               varchar2(255 byte),
    middle_name              varchar2(255 byte),
    last_name                varchar2(255 byte),
    gender                   varchar2(30 byte),
    address                  varchar2(255 byte),
    city                     varchar2(255 byte),
    state                    varchar2(30 byte),
    zip                      varchar2(30 byte),
    day_phone                varchar2(30 byte),
    email_address            varchar2(100 byte),
    birth_date               varchar2(30 byte),
    ssn                      varchar2(30 byte),
    debit_card               varchar2(30 byte),
    division_code            varchar2(30 byte),
    coverage_tier_name       varchar2(255 byte),
    health_fsa_flag          varchar2(30 byte),
    hfsa_effective_date      varchar2(30 byte),
    hfsa_annual_election     number,
    post_ded_fsa_flag        varchar2(30 byte),
    post_ded_effective_date  varchar2(30 byte),
    post_ded_annual_election number,
    dep_fsa_flag             varchar2(30 byte),
    dfsa_effective_date      varchar2(30 byte),
    dfsa_annual_election     number,
    transit_fsa_flag         varchar2(30 byte),
    transit_effective_date   varchar2(30 byte),
    transit_annual_election  number,
    parking_fsa_flag         varchar2(30 byte),
    parking_effective_date   varchar2(30 byte),
    parking_annual_election  number,
    bicycle_fsa_flag         varchar2(30 byte),
    bicycle_effective_date   varchar2(30 byte),
    bicycle_annual_election  number,
    group_number             varchar2(30 byte),
    conditional_issue        varchar2(30 byte),
    broker_number            varchar2(300 byte),
    note                     varchar2(3200 byte),
    acc_num                  varchar2(30 byte),
    hra_fsa_flag             varchar2(30 byte),
    hra_effective_date       varchar2(30 byte),
    hra_annual_election      number
)
organization external ( type oracle_loader
    default directory enroll_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'SanDiegoImaging_TEST_02012016.csv.bad'
            logfile 'SanDiegoImaging_TEST_02012016.csv.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( enroll_dir : 'SanDiegoImaging_TEST_02012016.csv' )
) reject limit 0;

