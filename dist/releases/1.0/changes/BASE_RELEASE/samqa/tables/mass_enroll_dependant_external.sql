-- liquibase formatted sql
-- changeset SAMQA:1754374160221 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\mass_enroll_dependant_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/mass_enroll_dependant_external.sql:null:caed6b8bba034774110bdbb553eaf591755a92dc:create

create table samqa.mass_enroll_dependant_external (
    subscriber_ssn       varchar2(30 byte),
    first_name           varchar2(255 byte),
    middle_name          varchar2(255 byte),
    last_name            varchar2(255 byte),
    gender               varchar2(30 byte),
    birth_date           varchar2(30 byte),
    ssn                  varchar2(30 byte),
    relative             varchar2(30 byte),
    dep_flag             varchar2(30 byte),
    beneficiary_type     varchar2(30 byte),
    beneficiary_relation varchar2(30 byte),
    effective_date       varchar2(12 byte),
    distiribution        varchar2(30 byte),
    account_type         varchar2(30 byte),
    acc_num              varchar2(30 byte),
    debit_card_flag      varchar2(10 byte),
    termination_date     varchar2(30 byte)
)
organization external ( type oracle_loader
    default directory enroll_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'enroll.bad'
            logfile 'enroll.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( enroll_dir : 'Dependent_Enrollment_HSA_SAM_temp.csv' )
) reject limit unlimited;

