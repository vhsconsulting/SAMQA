-- liquibase formatted sql
-- changeset SAMQA:1754374163232 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\settlement_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/settlement_external.sql:null:60eed02c4f08c9a3e049a2d6e034f6e5d9099cf8:create

create table samqa.settlement_external (
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
    plan_type                varchar2(255 byte)
)
organization external ( type oracle_loader
    default directory debit_dir access parameters (
        records delimited by newline
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( debit_card_dir : 'fivekeys.csv' )
) reject limit unlimited;

