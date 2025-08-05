-- liquibase formatted sql
-- changeset SAMQA:1754374152736 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\card_balance_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/card_balance_external.sql:null:dccb552b96a82bff7c7e72c9b17f0dd63d96684d:create

create table samqa.card_balance_external (
    record_id                 varchar2(30 byte),
    tpa_id                    varchar2(30 byte),
    employee_id               varchar2(30 byte),
    account_status            varchar2(30 byte),
    card_number               varchar2(30 byte),
    available_balance         varchar2(30 byte),
    disbursable_balance       varchar2(30 byte),
    employee_contribution_ytd varchar2(30 byte),
    pre_auth_hold_balance     varchar2(30 byte),
    dependant_id              varchar2(30 byte),
    employer_id               varchar2(30 byte),
    plan_id                   varchar2(30 byte),
    plan_type                 varchar2(30 byte),
    plan_start_date           varchar2(30 byte),
    plan_end_date             varchar2(30 byte),
    annual_election           varchar2(30 byte),
    disb_ptd                  number,
    deductible_ptd            number,
    disb_ytd                  varchar2(100 byte),
    employer_contribution_ytd number,
    effective_date            varchar2(30 byte),
    termination_date          varchar2(30 byte)
)
organization external ( type oracle_loader
    default directory debit_card_dir access parameters (
        records delimited by newline
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( debit_card_dir : 'MB_6800012_EC.exp' )
) reject limit unlimited;

