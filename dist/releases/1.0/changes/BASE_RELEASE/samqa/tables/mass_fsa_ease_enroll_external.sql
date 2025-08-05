-- liquibase formatted sql
-- changeset SAMQA:1754374160462 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\mass_fsa_ease_enroll_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/mass_fsa_ease_enroll_external.sql:null:05969e228943484f04abedd04285afc3cd2d2ac7:create

create table samqa.mass_fsa_ease_enroll_external (
    client_id                      varchar2(500 byte),
    company                        varchar2(500 byte),
    location                       varchar2(500 byte),
    action                         varchar2(500 byte),
    employee_id                    varchar2(500 byte),
    ssn                            varchar2(500 byte),
    first_name                     varchar2(500 byte),
    middle_name                    varchar2(500 byte),
    last_name                      varchar2(500 byte),
    sex                            varchar2(500 byte),
    birth_date                     varchar2(500 byte),
    address_1                      varchar2(500 byte),
    address_2                      varchar2(500 byte),
    city                           varchar2(500 byte),
    state                          varchar2(500 byte),
    zip                            varchar2(500 byte),
    country                        varchar2(500 byte),
    email                          varchar2(500 byte),
    hire_date                      varchar2(500 byte),
    termination_date               varchar2(500 byte),
    pay_cycle                      varchar2(500 byte),
    policy_number                  varchar2(500 byte),
    subgroup_number                varchar2(500 byte),
    plan_year_effective_date       varchar2(500 byte),
    plan_year_end_date             varchar2(500 byte),
    carrier                        varchar2(500 byte),
    plan_type                      varchar2(500 byte),
    admin_name                     varchar2(500 byte),
    display_name                   varchar2(500 byte),
    coverage                       varchar2(500 byte),
    election                       varchar2(500 byte),
    employee_cost_deduction_period varchar2(500 byte),
    effective_date                 varchar2(500 byte),
    benefit_termination_date       varchar2(500 byte),
    employer_cost_deduction_period varchar2(500 byte),
    deduction_pay_periods          varchar2(500 byte),
    employee_status                varchar2(500 byte),
    scheduled_hours                varchar2(500 byte),
    bank_name                      varchar2(500 byte),
    bank_account_type              varchar2(500 byte),
    bank_routing_number            varchar2(500 byte),
    bank_account_number            varchar2(500 byte),
    demographic_changes            varchar2(500 byte),
    activity_date                  varchar2(500 byte),
    plan_name_code                 varchar2(500 byte),
    coverage_tier                  varchar2(500 byte),
    coverage_tier_code             varchar2(500 byte)
)
organization external ( type oracle_loader
    default directory enroll_dir access parameters (
        records delimited by newline
            skip 1
            badfile '883987791_ELI_2025-04-22_223F84.csv.bad'
            logfile '883987791_ELI_2025-04-22_223F84.csv.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( enroll_dir : '883987791_ELI_2025-04-22_223F84.csv' )
) reject limit 0;

