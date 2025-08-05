-- liquibase formatted sql
-- changeset SAMQA:1754374151764 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ar_quote_headers_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ar_quote_headers_staging.sql:null:58c28a58dc5caffcfd08ea8740a55b5db82f5a2f:create

create table samqa.ar_quote_headers_staging (
    quote_header_id      number,
    quote_name           varchar2(255 byte),
    quote_number         number,
    total_quote_price    number,
    discount_amount      number,
    quote_status         varchar2(1 byte),
    quote_date           date,
    quote_source         varchar2(50 byte),
    entrp_id             number,
    batch_number         number,
    notes                varchar2(100 byte),
    payment_method       varchar2(30 byte),
    bank_acct_id         number,
    ben_plan_id          number,
    account_type         varchar2(100 byte),
    creation_date        date,
    created_by           number,
    last_update_date     date,
    last_updated_by      number,
    enrollment_detail_id number(10, 0),
    billing_frequency    varchar2(1 byte) default 'A'
);

