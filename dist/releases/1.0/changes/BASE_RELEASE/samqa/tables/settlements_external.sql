-- liquibase formatted sql
-- changeset SAMQA:1754374163247 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\settlements_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/settlements_external.sql:null:f990f8be8b7b44ca02c0895d505d3c0e14844ab6:create

create table samqa.settlements_external (
    record_id                varchar2(30 byte),
    employee_id              varchar2(30 byte),
    merchant_name            varchar2(255 byte),
    transaction_amount       varchar2(30 byte),
    transaction_code         varchar2(30 byte),
    transaction_status       varchar2(30 byte),
    transaction_date         varchar2(30 byte),
    approval_code            varchar2(30 byte),
    disbursable_balance      varchar2(30 byte),
    effective_date           varchar2(30 byte),
    pos_flag                 varchar2(30 byte),
    pre_auth_hold_balance    varchar2(30 byte),
    settlement_date          varchar2(30 byte),
    settlement_seq_number    varchar2(30 byte),
    terminal_city            varchar2(255 byte),
    terminal_state           varchar2(255 byte),
    terminal_name            varchar2(255 byte),
    detail_response_code     varchar2(30 byte),
    origin_code              varchar2(30 byte),
    mcc_code                 varchar2(255 byte),
    transaction_process_code varchar2(255 byte),
    plan_type                varchar2(30 byte),
    plan_start_date          varchar2(12 byte),
    plan_end_date            varchar2(12 byte),
    card_number              varchar2(30 byte)
)
organization external ( type oracle_loader
    default directory debit_card_dir access parameters (
        records delimited by newline
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( debit_card_dir : 'MB_6799990_EN.exp' )
) reject limit unlimited;

