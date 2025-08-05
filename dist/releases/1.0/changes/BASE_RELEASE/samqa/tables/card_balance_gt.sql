-- liquibase formatted sql
-- changeset SAMQA:1754374152753 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\card_balance_gt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/card_balance_gt.sql:null:b3ac8a96e6b339372ceb5bf23677b91a096d87c2:create

create global temporary table samqa.card_balance_gt (
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
) on commit delete rows;

