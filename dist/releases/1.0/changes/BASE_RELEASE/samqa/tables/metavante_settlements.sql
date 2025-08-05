-- liquibase formatted sql
-- changeset SAMQA:1754374160765 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\metavante_settlements.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/metavante_settlements.sql:null:18fea5de1dcb6b90e5832035e0fd7c9280d2df96:create

create table samqa.metavante_settlements (
    settlement_number     number,
    acc_num               varchar2(255 byte),
    acc_id                number,
    merchant_name         varchar2(255 byte),
    mcc_code              varchar2(255 byte),
    transaction_amount    varchar2(30 byte),
    transaction_code      varchar2(30 byte),
    transaction_status    varchar2(30 byte),
    transaction_date      varchar2(30 byte),
    approval_code         varchar2(30 byte),
    disbursable_balance   varchar2(30 byte),
    effective_date        varchar2(30 byte),
    pos_flag              varchar2(30 byte),
    origin_code           varchar2(30 byte),
    pre_auth_hold_balance varchar2(30 byte),
    settlement_date       varchar2(30 byte),
    terminal_city         varchar2(30 byte),
    terminal_name         varchar2(30 byte),
    detail_response_code  varchar2(30 byte),
    created_claim         varchar2(30 byte),
    claim_id              varchar2(30 byte),
    last_update_date      date,
    creation_date         date,
    plan_type             varchar2(30 byte),
    plan_start_date       varchar2(12 byte),
    plan_end_date         varchar2(12 byte),
    card_number           varchar2(30 byte)
);

