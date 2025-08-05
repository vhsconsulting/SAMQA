-- liquibase formatted sql
-- changeset SAMQA:1754374151741 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ar_quote_headers.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ar_quote_headers.sql:null:398986588b87694c20a55d2e598663402967f961:create

create table samqa.ar_quote_headers (
    quote_header_id             number,
    quote_name                  varchar2(255 byte),
    quote_number                number,
    total_quote_price           number,
    discount_amount             number,
    quote_status                varchar2(1 byte),
    quote_date                  date,
    quote_source                varchar2(50 byte),
    entrp_id                    number,
    batch_number                number,
    notes                       varchar2(100 byte),
    payment_method              varchar2(30 byte),
    bank_acct_id                number,
    creation_date               date default sysdate,
    created_by                  number,
    last_update_date            date,
    last_updated_by             number,
    ben_plan_id                 number,
    ben_plan_number             varchar2(30 byte),
    billing_frequency           varchar2(1 byte),
    pay_acct_fees               varchar2(100 byte),
    optional_fee_bank_acct_id   number,
    optional_fee_payment_method varchar2(100 byte)
);

alter table samqa.ar_quote_headers add primary key ( quote_header_id )
    using index enable;

