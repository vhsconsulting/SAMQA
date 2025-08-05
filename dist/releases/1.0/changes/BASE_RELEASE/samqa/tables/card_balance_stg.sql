-- liquibase formatted sql
-- changeset SAMQA:1754374152772 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\card_balance_stg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/card_balance_stg.sql:null:644cc6c95642d2dc6373eb1a915aa4e117e343a3:create

create table samqa.card_balance_stg (
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
    annual_election           varchar2(30 byte)
);

