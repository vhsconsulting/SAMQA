-- liquibase formatted sql
-- changeset SAMQA:1754374154545 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\debit_card_settlement.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/debit_card_settlement.sql:null:f2176cd6b3fdc5a161da6dc17147911ccb9c9b40:create

create table samqa.debit_card_settlement (
    settle_num            number,
    file_name             varchar2(120 byte),
    file_date             date,
    file_time             number,
    tpa_id                varchar2(6 byte),
    processed_date        date,
    line                  number,
    client_id             varchar2(100 byte),
    transaction_date      varchar2(8 byte),
    description           varchar2(100 byte),
    payment_amount        varchar2(100 byte),
    transaction_code      varchar2(100 byte),
    claim_created         varchar2(10 byte),
    member_id             varchar2(100 byte),
    ssn                   varchar2(100 byte),
    purse_type            varchar2(100 byte),
    merchant_name         varchar2(100 byte),
    mcc                   varchar2(100 byte),
    payment_ref_number    varchar2(100 byte),
    transaction_source    varchar2(100 byte),
    matching_trans_id     varchar2(100 byte),
    plan_year_start_date  varchar2(8 byte),
    plan_year_end_date    varchar2(8 byte),
    transaction_unique_id varchar2(100 byte),
    ssn_count             number,
    status                varchar2(30 byte),
    message               varchar2(4000 byte)
);

