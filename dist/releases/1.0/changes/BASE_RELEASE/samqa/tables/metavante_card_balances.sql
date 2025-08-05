-- liquibase formatted sql
-- changeset SAMQA:1754374160605 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\metavante_card_balances.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/metavante_card_balances.sql:null:bf64f879fe4e7f3f93e071fdeaf1dae2d14138fa:create

create table samqa.metavante_card_balances (
    metavante_card_balance_id number,
    acc_num                   varchar2(30 byte),
    account_status            varchar2(30 byte),
    card_number               varchar2(30 byte),
    available_balance         varchar2(30 byte),
    disbursable_balance       varchar2(30 byte),
    employee_contribution_ytd varchar2(30 byte),
    pre_auth_hold_balanc      varchar2(30 byte),
    last_upload_status        varchar2(30 byte),
    upload_error_code         varchar2(30 byte),
    last_update_date          date,
    creation_date             date,
    employer_id               varchar2(30 byte),
    plan_id                   varchar2(30 byte),
    plan_type                 varchar2(30 byte),
    plan_start_date           date,
    plan_end_date             date,
    annual_election           number,
    acc_id                    number,
    effective_date            date,
    termination_date          date
);

